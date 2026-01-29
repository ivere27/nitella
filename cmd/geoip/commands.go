package main

import (
	"fmt"
	"strings"
	"time"

	pbCommon "github.com/ivere27/nitella/pkg/api/common"
	pb "github.com/ivere27/nitella/pkg/api/geoip"
	"github.com/ivere27/nitella/pkg/shell"
	"google.golang.org/protobuf/types/known/emptypb"
)

// cmdLookup performs IP geolocation lookup.
func (c *Client) cmdLookup(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: lookup <ip>")
	}

	ip := args[0]
	resp, err := c.admin.Lookup(c.ctx(), &pb.LookupRequest{Ip: ip})
	if err != nil {
		return fmt.Errorf("lookup failed: %v", err)
	}

	printGeoInfo(resp)
	return nil
}

// printGeoInfo prints GeoInfo nicely formatted.
func printGeoInfo(info *pbCommon.GeoInfo) {
	fmt.Printf("\n%s%s%s\n", shell.Bold, "GeoIP Result", shell.Reset)
	fmt.Printf("%-14s %s\n", "Country:", fmt.Sprintf("%s (%s)", info.Country, info.CountryCode))
	if info.RegionName != "" {
		fmt.Printf("%-14s %s (%s)\n", "Region:", info.RegionName, info.Region)
	}
	if info.City != "" {
		fmt.Printf("%-14s %s\n", "City:", info.City)
	}
	if info.Zip != "" {
		fmt.Printf("%-14s %s\n", "Postal:", info.Zip)
	}
	if info.Latitude != 0 || info.Longitude != 0 {
		fmt.Printf("%-14s %.4f, %.4f\n", "Coordinates:", info.Latitude, info.Longitude)
	}
	if info.Timezone != "" {
		fmt.Printf("%-14s %s\n", "Timezone:", info.Timezone)
	}
	if info.Isp != "" {
		fmt.Printf("%-14s %s\n", "ISP:", info.Isp)
	}
	if info.Org != "" {
		fmt.Printf("%-14s %s\n", "Organization:", info.Org)
	}
	if info.As != "" {
		fmt.Printf("%-14s %s\n", "AS:", info.As)
	}
	fmt.Printf("%-14s %s\n", "Source:", info.Source)
	fmt.Printf("%-14s %dms\n", "Latency:", info.LatencyMs)
	fmt.Println()
}

// cmdStatus shows server status.
func (c *Client) cmdStatus() error {
	resp, err := c.admin.GetStatus(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("status failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "GeoIP Server Status", shell.Reset)
	fmt.Printf("%-16s %s\n", "Ready:", boolStatus(resp.Ready))
	fmt.Printf("%-16s %d\n", "L1 Cache Size:", resp.L1CacheSize)
	fmt.Printf("%-16s %d\n", "L2 Cache Size:", resp.L2CacheSize)
	fmt.Printf("%-16s %s\n", "Local DB:", boolStatus(resp.LocalDbLoaded))
	fmt.Printf("%-16s %s\n", "Strategy:", resp.Strategy)
	fmt.Printf("%-16s %s\n", "Providers:", strings.Join(resp.ActiveProviders, ", "))
	fmt.Println()

	return nil
}

func boolStatus(b bool) string {
	if b {
		return shell.Success("Yes")
	}
	return shell.Error("No")
}

// cmdProvider handles provider management commands.
func (c *Client) cmdProvider(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: provider <list|add|remove|enable|disable|stats|order>")
	}

	subcmd := args[0]
	subargs := args[1:]

	switch subcmd {
	case "list":
		return c.providerList()
	case "add":
		return c.providerAdd(subargs)
	case "remove":
		return c.providerRemove(subargs)
	case "enable":
		return c.providerEnable(subargs)
	case "disable":
		return c.providerDisable(subargs)
	case "stats":
		return c.providerStats(subargs)
	case "order":
		return c.providerOrder(subargs)
	default:
		return fmt.Errorf("unknown provider command: %s", subcmd)
	}
}

func (c *Client) providerList() error {
	resp, err := c.admin.ListProviders(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("list providers failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "Remote Providers", shell.Reset)

	if len(resp.Providers) == 0 {
		fmt.Println("No providers configured")
		return nil
	}

	headers := []string{"#", "Name", "Enabled", "URL", "Success", "Errors", "Avg(ms)"}
	rows := make([][]string, 0, len(resp.Providers))

	for _, p := range resp.Providers {
		enabled := shell.Success("Yes")
		if !p.Enabled {
			enabled = shell.Error("No")
		}

		avgLatency := int64(0)
		if p.Stats != nil {
			avgLatency = p.Stats.AvgLatencyMs
		}

		rows = append(rows, []string{
			fmt.Sprintf("%d", p.Priority),
			p.Name,
			enabled,
			shell.Truncate(p.Url, 40),
			fmt.Sprintf("%d", p.Stats.SuccessCount),
			fmt.Sprintf("%d", p.Stats.ErrorCount),
			fmt.Sprintf("%d", avgLatency),
		})
	}

	shell.PrintTable(headers, rows)
	fmt.Println()
	return nil
}

func (c *Client) providerAdd(args []string) error {
	if len(args) < 2 {
		return fmt.Errorf("usage: provider add <name> <url>")
	}

	name, url := args[0], stripQuotes(args[1])

	resp, err := c.admin.AddProvider(c.ctx(), &pb.AddProviderRequest{
		Name: name,
		Url:  url,
	})
	if err != nil {
		return fmt.Errorf("add provider failed: %v", err)
	}

	fmt.Printf("%s Added provider: %s (priority %d)\n", shell.Success("OK"), resp.Name, resp.Priority)
	return nil
}

func (c *Client) providerRemove(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: provider remove <name>")
	}

	name := args[0]

	_, err := c.admin.RemoveProvider(c.ctx(), &pb.RemoveProviderRequest{Name: name})
	if err != nil {
		return fmt.Errorf("remove provider failed: %v", err)
	}

	fmt.Printf("%s Removed provider: %s\n", shell.Success("OK"), name)
	return nil
}

func (c *Client) providerEnable(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: provider enable <name>")
	}

	name := args[0]

	_, err := c.admin.EnableProvider(c.ctx(), &pb.ProviderNameRequest{Name: name})
	if err != nil {
		return fmt.Errorf("enable provider failed: %v", err)
	}

	fmt.Printf("%s Enabled provider: %s\n", shell.Success("OK"), name)
	return nil
}

func (c *Client) providerDisable(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: provider disable <name>")
	}

	name := args[0]

	_, err := c.admin.DisableProvider(c.ctx(), &pb.ProviderNameRequest{Name: name})
	if err != nil {
		return fmt.Errorf("disable provider failed: %v", err)
	}

	fmt.Printf("%s Disabled provider: %s\n", shell.Success("OK"), name)
	return nil
}

func (c *Client) providerStats(args []string) error {
	if len(args) < 1 {
		// Show all providers
		return c.providerList()
	}

	name := args[0]

	stats, err := c.admin.GetProviderStats(c.ctx(), &pb.ProviderNameRequest{Name: name})
	if err != nil {
		return fmt.Errorf("get stats failed: %v", err)
	}

	fmt.Printf("\n%s%s Provider Stats%s\n", shell.Bold, name, shell.Reset)
	fmt.Printf("%-16s %d\n", "Lookups:", stats.LookupCount)
	fmt.Printf("%-16s %d\n", "Successes:", stats.SuccessCount)
	fmt.Printf("%-16s %d\n", "Errors:", stats.ErrorCount)
	fmt.Printf("%-16s %dms\n", "Total Latency:", stats.TotalLatencyMs)
	fmt.Printf("%-16s %dms\n", "Avg Latency:", stats.AvgLatencyMs)
	if stats.LastUsedUnix > 0 {
		lastUsed := time.Unix(stats.LastUsedUnix, 0)
		fmt.Printf("%-16s %s\n", "Last Used:", lastUsed.Format(time.RFC3339))
	}
	if stats.LastError != "" {
		fmt.Printf("%-16s %s\n", "Last Error:", shell.Error(stats.LastError))
	}
	fmt.Println()

	return nil
}

func (c *Client) providerOrder(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: provider order <name1> <name2> ...")
	}

	_, err := c.admin.ReorderProviders(c.ctx(), &pb.ReorderProvidersRequest{
		ProviderNames: args,
	})
	if err != nil {
		return fmt.Errorf("reorder failed: %v", err)
	}

	fmt.Printf("%s Providers reordered\n", shell.Success("OK"))
	return nil
}

// cmdLocalDB handles local database commands.
func (c *Client) cmdLocalDB(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: localdb <load|unload|status>")
	}

	subcmd := args[0]
	subargs := args[1:]

	switch subcmd {
	case "load":
		return c.localDBLoad(subargs)
	case "unload":
		return c.localDBUnload()
	case "status":
		return c.localDBStatus()
	default:
		return fmt.Errorf("unknown localdb command: %s", subcmd)
	}
}

func (c *Client) localDBLoad(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: localdb load <city_db_path> [isp_db_path]")
	}

	cityPath := args[0]
	ispPath := ""
	if len(args) > 1 {
		ispPath = args[1]
	}

	_, err := c.admin.LoadLocalDB(c.ctx(), &pb.LoadLocalDBRequest{
		CityDbPath: cityPath,
		IspDbPath:  ispPath,
	})
	if err != nil {
		return fmt.Errorf("load local DB failed: %v", err)
	}

	fmt.Printf("%s Local DB loaded\n", shell.Success("OK"))
	return nil
}

func (c *Client) localDBUnload() error {
	_, err := c.admin.UnloadLocalDB(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("unload local DB failed: %v", err)
	}

	fmt.Printf("%s Local DB unloaded\n", shell.Success("OK"))
	return nil
}

func (c *Client) localDBStatus() error {
	resp, err := c.admin.GetLocalDBStatus(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("get local DB status failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "Local Database Status", shell.Reset)
	fmt.Printf("%-14s %s\n", "Loaded:", boolStatus(resp.Loaded))
	if resp.CityDbPath != "" {
		fmt.Printf("%-14s %s (%s)\n", "City DB:", resp.CityDbPath, shell.FormatBytes(resp.CityDbSize))
	}
	if resp.IspDbPath != "" {
		fmt.Printf("%-14s %s (%s)\n", "ISP DB:", resp.IspDbPath, shell.FormatBytes(resp.IspDbSize))
	}
	fmt.Println()

	return nil
}

// cmdCache handles cache commands.
func (c *Client) cmdCache(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: cache <stats|clear|settings>")
	}

	subcmd := args[0]
	subargs := args[1:]

	switch subcmd {
	case "stats":
		return c.cacheStats()
	case "clear":
		return c.cacheClear(subargs)
	case "settings":
		return c.cacheSettings()
	default:
		return fmt.Errorf("unknown cache command: %s", subcmd)
	}
}

func (c *Client) cacheStats() error {
	resp, err := c.admin.GetCacheStats(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("get cache stats failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "Cache Statistics", shell.Reset)

	// L1
	fmt.Printf("\n%sL1 (Memory)%s\n", shell.Cyan, shell.Reset)
	fmt.Printf("  %-12s %d / %d\n", "Size:", resp.L1Size, resp.L1Capacity)
	fmt.Printf("  %-12s %d\n", "Hits:", resp.L1Hits)
	fmt.Printf("  %-12s %d\n", "Misses:", resp.L1Misses)
	if resp.L1Hits+resp.L1Misses > 0 {
		hitRate := float64(resp.L1Hits) / float64(resp.L1Hits+resp.L1Misses) * 100
		fmt.Printf("  %-12s %.1f%%\n", "Hit Rate:", hitRate)
	}

	// L2
	fmt.Printf("\n%sL2 (SQLite)%s\n", shell.Cyan, shell.Reset)
	fmt.Printf("  %-12s %s\n", "Enabled:", boolStatus(resp.L2Enabled))
	if resp.L2Enabled {
		fmt.Printf("  %-12s %s\n", "Path:", resp.L2Path)
		fmt.Printf("  %-12s %d\n", "Size:", resp.L2Size)
		fmt.Printf("  %-12s %d\n", "Hits:", resp.L2Hits)
		fmt.Printf("  %-12s %d\n", "Misses:", resp.L2Misses)
		if resp.L2TtlHours == 0 {
			fmt.Printf("  %-12s %s\n", "TTL:", "permanent")
		} else {
			fmt.Printf("  %-12s %dh\n", "TTL:", resp.L2TtlHours)
		}
	}

	fmt.Println()
	return nil
}

func (c *Client) cacheClear(args []string) error {
	layer := pb.CacheLayer_CACHE_LAYER_ALL
	layerName := "all"

	if len(args) > 0 {
		switch args[0] {
		case "l1":
			layer = pb.CacheLayer_CACHE_LAYER_L1
			layerName = "L1"
		case "l2":
			layer = pb.CacheLayer_CACHE_LAYER_L2
			layerName = "L2"
		case "all":
			layer = pb.CacheLayer_CACHE_LAYER_ALL
			layerName = "all"
		default:
			return fmt.Errorf("unknown cache layer: %s (use l1, l2, or all)", args[0])
		}
	}

	_, err := c.admin.ClearCache(c.ctx(), &pb.ClearCacheRequest{Layer: layer})
	if err != nil {
		return fmt.Errorf("clear cache failed: %v", err)
	}

	fmt.Printf("%s Cleared %s cache\n", shell.Success("OK"), layerName)
	return nil
}

func (c *Client) cacheSettings() error {
	resp, err := c.admin.GetCacheSettings(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("get cache settings failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "Cache Settings", shell.Reset)
	fmt.Printf("\n%sL1%s\n", shell.Cyan, shell.Reset)
	fmt.Printf("  %-12s %d\n", "Capacity:", resp.L1Capacity)
	fmt.Printf("  %-12s %dh\n", "TTL:", resp.L1TtlHours)

	fmt.Printf("\n%sL2%s\n", shell.Cyan, shell.Reset)
	fmt.Printf("  %-12s %s\n", "Enabled:", boolStatus(resp.L2Enabled))
	if resp.L2Enabled {
		fmt.Printf("  %-12s %s\n", "Path:", resp.L2Path)
		if resp.L2TtlHours == 0 {
			fmt.Printf("  %-12s %s\n", "TTL:", "permanent (no expiration)")
		} else {
			fmt.Printf("  %-12s %dh\n", "TTL:", resp.L2TtlHours)
		}
	}

	fmt.Println()
	return nil
}

// cmdStrategy handles strategy commands.
func (c *Client) cmdStrategy(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: strategy <show|set>")
	}

	subcmd := args[0]
	subargs := args[1:]

	switch subcmd {
	case "show":
		return c.strategyShow()
	case "set":
		return c.strategySet(subargs)
	default:
		return fmt.Errorf("unknown strategy command: %s", subcmd)
	}
}

func (c *Client) strategyShow() error {
	resp, err := c.admin.GetStrategy(c.ctx(), &emptypb.Empty{})
	if err != nil {
		return fmt.Errorf("get strategy failed: %v", err)
	}

	fmt.Printf("\n%s%s%s\n", shell.Bold, "Lookup Strategy", shell.Reset)
	fmt.Printf("%-12s %s\n", "Order:", strings.Join(resp.Steps, " -> "))
	fmt.Printf("%-12s %dms\n", "Timeout:", resp.TimeoutMs)
	fmt.Println()

	return nil
}

func (c *Client) strategySet(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: strategy set <l1,l2,local,remote>")
	}

	// Accept comma-separated or space-separated
	var steps []string
	if strings.Contains(args[0], ",") {
		steps = strings.Split(args[0], ",")
	} else {
		steps = args
	}

	_, err := c.admin.SetStrategy(c.ctx(), &pb.SetStrategyRequest{Steps: steps})
	if err != nil {
		return fmt.Errorf("set strategy failed: %v", err)
	}

	fmt.Printf("%s Strategy updated: %s\n", shell.Success("OK"), strings.Join(steps, " -> "))
	return nil
}

// cmdConfig handles configuration commands.
func (c *Client) cmdConfig(args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: config <reload|save>")
	}

	subcmd := args[0]

	switch subcmd {
	case "reload":
		_, err := c.admin.ReloadConfig(c.ctx(), &emptypb.Empty{})
		if err != nil {
			return fmt.Errorf("reload config failed: %v", err)
		}
		fmt.Printf("%s Configuration reloaded\n", shell.Success("OK"))

	case "save":
		_, err := c.admin.SaveConfig(c.ctx(), &emptypb.Empty{})
		if err != nil {
			return fmt.Errorf("save config failed: %v", err)
		}
		fmt.Printf("%s Configuration saved\n", shell.Success("OK"))

	default:
		return fmt.Errorf("unknown config command: %s", subcmd)
	}

	return nil
}

// stripQuotes removes surrounding quotes from a string.
func stripQuotes(s string) string {
	if len(s) >= 2 {
		if (s[0] == '"' && s[len(s)-1] == '"') || (s[0] == '\'' && s[len(s)-1] == '\'') {
			return s[1 : len(s)-1]
		}
	}
	return s
}
