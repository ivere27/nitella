use crate::mobile_service::MobileLogicService;
use lazy_static::lazy_static;
use std::collections::HashMap;
use std::ffi::CStr;
use std::os::raw::{c_char, c_int, c_longlong, c_void};
use std::ptr;
use std::slice;
use std::sync::atomic::{AtomicI64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};
use tokio::runtime::Runtime;

#[repr(C)]
pub struct CoreArgument {
    pub storage_path: *mut c_char,
    pub cache_path: *mut c_char,
    pub engine_socket_path: *mut c_char,
    pub engine_tcp_port: *mut c_char,
    pub view_socket_path: *mut c_char,
    pub view_tcp_port: *mut c_char,
    pub token: *mut c_char,
    pub enable_cache: c_int,
    pub stream_timeout: c_longlong,
}

#[repr(C)]
pub struct FfiData {
    pub data: *mut c_void,
    pub len: c_longlong,
}

// Callback signature: void (*InvokeDartCallback)(long long requestId, char* method, void* data, long long len);
pub type InvokeDartCallback = extern "C" fn(c_longlong, *mut c_char, *mut c_void, c_longlong);

// Callback signature: void (*StreamCallback)(long long streamId, char msgType, void* data, long long len);
pub type StreamCallback = extern "C" fn(c_longlong, c_char, *mut c_void, c_longlong);

lazy_static! {
    static ref RUNTIME: Mutex<Option<Runtime>> = Mutex::new(None);
    static ref SERVICE: Mutex<Option<Arc<MobileLogicService>>> = Mutex::new(None);
    static ref DART_CALLBACK: Mutex<Option<InvokeDartCallback>> = Mutex::new(None);
    static ref STREAM_CALLBACK: Mutex<Option<StreamCallback>> = Mutex::new(None);
    static ref STREAMS: Mutex<HashMap<i64, StreamState>> = Mutex::new(HashMap::new());
    static ref CACHE: Mutex<HashMap<(String, String), CacheEntry>> = Mutex::new(HashMap::new());
}

static NEXT_STREAM_ID: AtomicI64 = AtomicI64::new(1);

struct StreamState {
    method: String,
    buffer: Vec<u8>,
}

struct CacheEntry {
    data: Vec<u8>,
    expires_at: Option<Instant>,
}

#[no_mangle]
pub extern "C" fn StartGrpcServer(args: CoreArgument) -> c_int {
    let mut runtime_lock = RUNTIME.lock().unwrap();
    if runtime_lock.is_some() {
        return 0; // Already started
    }

    let rt = match Runtime::new() {
        Ok(r) => r,
        Err(_) => return -1,
    };

    let storage_path = unsafe {
        if !args.storage_path.is_null() {
            CStr::from_ptr(args.storage_path)
                .to_string_lossy()
                .to_string()
        } else {
            ".".to_string()
        }
    };

    // Initialize Service
    let service = Arc::new(MobileLogicService::new(storage_path));

    // Run initialization logic async
    let service_clone = service.clone();
    rt.block_on(async move {
        let _ = service_clone.initialize().await;
    });

    *SERVICE.lock().unwrap() = Some(service);
    *runtime_lock = Some(rt);

    0
}

#[no_mangle]
pub extern "C" fn StopGrpcServer() -> c_int {
    let mut runtime_lock = RUNTIME.lock().unwrap();
    if runtime_lock.is_none() {
        return 0;
    }

    // Shutdown service logic if needed
    {
        let mut service_lock = SERVICE.lock().unwrap();
        *service_lock = None;
    }

    // Dropping the runtime shuts it down
    *runtime_lock = None;
    0
}

#[no_mangle]
pub extern "C" fn InvokeBackend(
    method: *mut c_char,
    data: *mut c_void,
    data_len: c_longlong,
) -> FfiData {
    let method_str = unsafe {
        if method.is_null() {
            return FfiData {
                data: ptr::null_mut(),
                len: 0,
            };
        }
        CStr::from_ptr(method).to_string_lossy().to_string()
    };

    let input_data = unsafe {
        if data.is_null() || data_len <= 0 {
            vec![]
        } else {
            slice::from_raw_parts(data as *const u8, data_len as usize).to_vec()
        }
    };

    let service_opt = SERVICE.lock().unwrap().clone();
    let runtime_lock = RUNTIME.lock().unwrap();

    if let (Some(service), Some(rt)) = (service_opt, runtime_lock.as_ref()) {
        let result = rt.block_on(async move { service.invoke(&method_str, input_data).await });

        match result {
            Ok(result) => {
                let (ptr, len) = alloc_c_buffer(&result);
                FfiData {
                    data: ptr,
                    len: len as c_longlong,
                }
            }
            Err(err) => ffi_error(&err),
        }
    } else {
        // Error: Service not initialized
        ffi_error("Service not initialized")
    }
}

#[no_mangle]
pub extern "C" fn InvokeBackendWithMeta(
    method: *mut c_char,
    data: *mut c_void,
    data_len: c_longlong,
    _meta: *mut c_void,
    _meta_len: c_longlong,
) -> FfiData {
    InvokeBackend(method, data, data_len)
}

#[no_mangle]
pub extern "C" fn FreeFfiData(data: *mut c_void) {
    if !data.is_null() {
        unsafe { libc::free(data) };
    }
}

#[no_mangle]
pub extern "C" fn RegisterDartCallback(cb: InvokeDartCallback) {
    *DART_CALLBACK.lock().unwrap() = Some(cb);
}

#[no_mangle]
pub extern "C" fn SendFfiResponse(
    _request_id: c_longlong,
    _data: *mut c_void,
    _data_len: c_longlong,
) {
    // Logic to handle async responses would go here (matching Go's pendingRequests)
    // For now, we stub it as we primarily use sync InvokeBackend for this MVP
}

#[no_mangle]
pub extern "C" fn RegisterStreamCallback(cb: StreamCallback) {
    *STREAM_CALLBACK.lock().unwrap() = Some(cb);
}
#[no_mangle]
pub extern "C" fn InvokeBackendServerStream(
    method: *mut c_char,
    data: *mut c_void,
    data_len: c_longlong,
) -> c_longlong {
    let Some(method) = c_string(method) else {
        return -1;
    };
    let input = c_bytes(data, data_len);
    let stream_id = next_stream_id();
    invoke_stream_once(stream_id, method, input);
    stream_id
}
#[no_mangle]
pub extern "C" fn InvokeBackendClientStream(method: *mut c_char) -> c_longlong {
    let Some(method) = c_string(method) else {
        return -1;
    };
    let stream_id = next_stream_id();
    STREAMS.lock().unwrap().insert(
        stream_id,
        StreamState {
            method,
            buffer: Vec::new(),
        },
    );
    stream_id
}
#[no_mangle]
pub extern "C" fn InvokeBackendBidiStream(method: *mut c_char) -> c_longlong {
    InvokeBackendClientStream(method)
}
#[no_mangle]
pub extern "C" fn SendStreamData(id: c_longlong, data: *mut c_void, data_len: c_longlong) -> c_int {
    let mut streams = STREAMS.lock().unwrap();
    let Some(stream) = streams.get_mut(&id) else {
        return -1;
    };
    stream.buffer.extend_from_slice(&c_bytes(data, data_len));
    0
}
#[no_mangle]
pub extern "C" fn CloseStream(id: c_longlong) {
    STREAMS.lock().unwrap().remove(&id);
    send_stream_callback(id, b'C', &[]);
}
#[no_mangle]
pub extern "C" fn CloseStreamInput(id: c_longlong) {
    let stream = STREAMS.lock().unwrap().remove(&id);
    if let Some(stream) = stream {
        invoke_stream_once(id, stream.method, stream.buffer);
    }
}
#[no_mangle]
pub extern "C" fn StreamReady(_id: c_longlong) {}
#[no_mangle]
pub extern "C" fn CacheGet(store_name: *mut c_char, key: *mut c_char) -> FfiData {
    let Some(store_name) = c_string(store_name) else {
        return empty_ffi_data();
    };
    let Some(key) = c_string(key) else {
        return empty_ffi_data();
    };
    let mut cache = CACHE.lock().unwrap();
    let cache_key = (store_name, key);
    if let Some(entry) = cache.get(&cache_key) {
        if entry
            .expires_at
            .map_or(true, |expires_at| expires_at > Instant::now())
        {
            let (ptr, len) = alloc_c_buffer(&entry.data);
            return FfiData {
                data: ptr,
                len: len as c_longlong,
            };
        }
    }
    cache.remove(&cache_key);
    empty_ffi_data()
}
#[no_mangle]
pub extern "C" fn CachePut(
    store_name: *mut c_char,
    key: *mut c_char,
    data: *mut c_void,
    data_len: c_longlong,
    ttl_seconds: c_longlong,
) -> c_int {
    let Some(store_name) = c_string(store_name) else {
        return -1;
    };
    let Some(key) = c_string(key) else {
        return -1;
    };
    let expires_at = if ttl_seconds > 0 {
        Some(Instant::now() + Duration::from_secs(ttl_seconds as u64))
    } else {
        None
    };
    CACHE.lock().unwrap().insert(
        (store_name, key),
        CacheEntry {
            data: c_bytes(data, data_len),
            expires_at,
        },
    );
    0
}
#[no_mangle]
pub extern "C" fn CacheContains(store_name: *mut c_char, key: *mut c_char) -> c_int {
    let Some(store_name) = c_string(store_name) else {
        return 0;
    };
    let Some(key) = c_string(key) else {
        return 0;
    };
    let mut cache = CACHE.lock().unwrap();
    let cache_key = (store_name, key);
    if let Some(entry) = cache.get(&cache_key) {
        if entry
            .expires_at
            .map_or(true, |expires_at| expires_at > Instant::now())
        {
            return 1;
        }
    }
    cache.remove(&cache_key);
    0
}
#[no_mangle]
pub extern "C" fn CacheDelete(store_name: *mut c_char, key: *mut c_char) -> c_int {
    let Some(store_name) = c_string(store_name) else {
        return -1;
    };
    let Some(key) = c_string(key) else {
        return -1;
    };
    CACHE.lock().unwrap().remove(&(store_name, key));
    0
}

// Helper to allocate buffer using libc::malloc
fn alloc_c_buffer(data: &[u8]) -> (*mut c_void, usize) {
    let len = data.len();
    unsafe {
        let ptr = libc::malloc(len) as *mut u8;
        if ptr.is_null() {
            return (ptr::null_mut(), 0);
        }
        ptr::copy_nonoverlapping(data.as_ptr(), ptr, len);
        (ptr as *mut c_void, len)
    }
}

fn ffi_error(message: &str) -> FfiData {
    let (ptr, len) = alloc_c_buffer(message.as_bytes());
    FfiData {
        data: ptr,
        len: -(len as c_longlong),
    }
}

fn empty_ffi_data() -> FfiData {
    FfiData {
        data: ptr::null_mut(),
        len: 0,
    }
}

fn c_string(value: *mut c_char) -> Option<String> {
    if value.is_null() {
        return None;
    }
    Some(unsafe { CStr::from_ptr(value).to_string_lossy().to_string() })
}

fn c_bytes(data: *mut c_void, data_len: c_longlong) -> Vec<u8> {
    if data.is_null() || data_len <= 0 {
        Vec::new()
    } else {
        unsafe { slice::from_raw_parts(data as *const u8, data_len as usize).to_vec() }
    }
}

fn next_stream_id() -> c_longlong {
    NEXT_STREAM_ID.fetch_add(1, Ordering::Relaxed)
}

fn invoke_stream_once(stream_id: c_longlong, method: String, data: Vec<u8>) {
    if STREAM_CALLBACK.lock().unwrap().is_none() {
        return;
    }
    let service_opt = SERVICE.lock().unwrap().clone();
    let runtime_lock = RUNTIME.lock().unwrap();
    let Some(service) = service_opt else {
        send_stream_callback(stream_id, b'E', b"Service not initialized");
        send_stream_callback(stream_id, b'C', &[]);
        return;
    };
    let Some(rt) = runtime_lock.as_ref() else {
        send_stream_callback(stream_id, b'E', b"Service not initialized");
        send_stream_callback(stream_id, b'C', &[]);
        return;
    };
    let result = rt.block_on(async move { service.invoke(&method, data).await });
    match result {
        Ok(payload) => send_stream_callback(stream_id, b'D', &payload),
        Err(err) => send_stream_callback(stream_id, b'E', err.as_bytes()),
    }
    send_stream_callback(stream_id, b'C', &[]);
}

fn send_stream_callback(stream_id: c_longlong, msg_type: u8, data: &[u8]) {
    let callback = *STREAM_CALLBACK.lock().unwrap();
    let Some(callback) = callback else {
        return;
    };
    let (ptr, len) = alloc_c_buffer(data);
    callback(stream_id, msg_type as c_char, ptr, len as c_longlong);
    if !ptr.is_null() {
        unsafe { libc::free(ptr) };
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::proto::local::{Settings, Theme};
    use prost::Message;
    use std::ffi::CString;
    use std::sync::OnceLock;

    static STREAM_TEST_EVENTS: OnceLock<Mutex<Vec<(c_longlong, u8, Vec<u8>)>>> = OnceLock::new();

    fn stream_test_events() -> &'static Mutex<Vec<(c_longlong, u8, Vec<u8>)>> {
        STREAM_TEST_EVENTS.get_or_init(|| Mutex::new(Vec::new()))
    }

    extern "C" fn test_stream_callback(
        stream_id: c_longlong,
        msg_type: c_char,
        data: *mut c_void,
        len: c_longlong,
    ) {
        let payload = if data.is_null() || len <= 0 {
            Vec::new()
        } else {
            unsafe { slice::from_raw_parts(data as *const u8, len as usize).to_vec() }
        };
        stream_test_events()
            .lock()
            .unwrap()
            .push((stream_id, msg_type as u8, payload));
    }

    #[test]
    fn cache_roundtrip_and_delete() {
        let store = CString::new("store").unwrap();
        let key = CString::new("key").unwrap();
        let mut value = b"value".to_vec();

        assert_eq!(
            CachePut(
                store.as_ptr() as *mut c_char,
                key.as_ptr() as *mut c_char,
                value.as_mut_ptr() as *mut c_void,
                value.len() as c_longlong,
                0,
            ),
            0
        );
        assert_eq!(
            CacheContains(store.as_ptr() as *mut c_char, key.as_ptr() as *mut c_char),
            1
        );
        let got = CacheGet(store.as_ptr() as *mut c_char, key.as_ptr() as *mut c_char);
        assert_eq!(got.len, 5);
        let got_slice = unsafe { slice::from_raw_parts(got.data as *const u8, got.len as usize) };
        assert_eq!(got_slice, b"value");
        FreeFfiData(got.data);

        assert_eq!(
            CacheDelete(store.as_ptr() as *mut c_char, key.as_ptr() as *mut c_char),
            0
        );
        assert_eq!(
            CacheContains(store.as_ptr() as *mut c_char, key.as_ptr() as *mut c_char),
            0
        );
    }

    #[test]
    fn mobile_ffi_invoke_backend_and_stream_get_settings_roundtrip() {
        let _ = StopGrpcServer();
        let dir =
            std::env::temp_dir().join(format!("nitella-mobile-ffi-test-{}", uuid::Uuid::new_v4()));
        std::fs::create_dir_all(&dir).unwrap();
        let storage = CString::new(dir.to_string_lossy().to_string()).unwrap();

        let args = CoreArgument {
            storage_path: storage.as_ptr() as *mut c_char,
            cache_path: ptr::null_mut(),
            engine_socket_path: ptr::null_mut(),
            engine_tcp_port: ptr::null_mut(),
            view_socket_path: ptr::null_mut(),
            view_tcp_port: ptr::null_mut(),
            token: ptr::null_mut(),
            enable_cache: 1,
            stream_timeout: 0,
        };

        assert_eq!(StartGrpcServer(args), 0);

        let method = CString::new("/nitella.local.MobileLogicService/GetSettings").unwrap();
        let response = InvokeBackend(method.as_ptr() as *mut c_char, ptr::null_mut(), 0);
        assert!(response.len > 0);
        let response_bytes =
            unsafe { slice::from_raw_parts(response.data as *const u8, response.len as usize) };
        let settings = Settings::decode(response_bytes).unwrap();
        assert_eq!(settings.theme, Theme::System as i32);
        FreeFfiData(response.data);

        stream_test_events().lock().unwrap().clear();
        RegisterStreamCallback(test_stream_callback);
        let stream_id =
            InvokeBackendServerStream(method.as_ptr() as *mut c_char, ptr::null_mut(), 0);
        assert!(stream_id > 0);

        let events = stream_test_events().lock().unwrap().clone();
        assert_eq!(events.len(), 2);
        assert_eq!(events[0].0, stream_id);
        assert_eq!(events[0].1, b'D');
        assert_eq!(events[1].0, stream_id);
        assert_eq!(events[1].1, b'C');
        let stream_settings = Settings::decode(events[0].2.as_slice()).unwrap();
        assert_eq!(stream_settings.theme, Theme::System as i32);

        assert_eq!(StopGrpcServer(), 0);
        let _ = std::fs::remove_dir_all(dir);
    }
}
