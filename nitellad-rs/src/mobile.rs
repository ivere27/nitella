use std::ffi::{CStr};
use std::os::raw::{c_char, c_int, c_longlong, c_void};
use std::ptr;
use std::slice;
use std::sync::{Arc, Mutex};
use lazy_static::lazy_static;
use tokio::runtime::Runtime;
use crate::mobile_service::MobileLogicService;

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
            CStr::from_ptr(args.storage_path).to_string_lossy().to_string()
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
pub extern "C" fn InvokeBackend(method: *mut c_char, data: *mut c_void, data_len: c_longlong) -> FfiData {
    let method_str = unsafe {
        if method.is_null() {
            return FfiData { data: ptr::null_mut(), len: 0 };
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
        let result = rt.block_on(async move {
            service.invoke(&method_str, input_data).await
        });

        // Copy result to C-compatible buffer
        let (ptr, len) = alloc_c_buffer(&result);
        FfiData { data: ptr, len: len as c_longlong }
    } else {
        // Error: Service not initialized
        let err_msg = "Service not initialized".as_bytes();
        let (ptr, len) = alloc_c_buffer(err_msg);
        // Negative length indicates error in some conventions, but FfiData usually just returns data.
        // The Go code returns error string with negative length?
        // Checking Go code: 
        // return C.FfiData{data: cErr, len: C.longlong(-len(errStr))}
        FfiData { data: ptr, len: -(len as c_longlong) }
    }
}

#[no_mangle]
pub extern "C" fn InvokeBackendWithMeta(
    method: *mut c_char, 
    data: *mut c_void, 
    data_len: c_longlong, 
    _meta: *mut c_void, 
    _meta_len: c_longlong
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
pub extern "C" fn SendFfiResponse(_request_id: c_longlong, _data: *mut c_void, _data_len: c_longlong) {
    // Logic to handle async responses would go here (matching Go's pendingRequests)
    // For now, we stub it as we primarily use sync InvokeBackend for this MVP
}

// Stubs for Streaming and Caching
#[no_mangle] pub extern "C" fn RegisterStreamCallback(_cb: StreamCallback) {}
#[no_mangle] pub extern "C" fn InvokeBackendServerStream(_m: *mut c_char, _d: *mut c_void, _l: c_longlong) -> c_longlong { -1 }
#[no_mangle] pub extern "C" fn InvokeBackendClientStream(_m: *mut c_char) -> c_longlong { -1 }
#[no_mangle] pub extern "C" fn InvokeBackendBidiStream(_m: *mut c_char) -> c_longlong { -1 }
#[no_mangle] pub extern "C" fn SendStreamData(_id: c_longlong, _d: *mut c_void, _l: c_longlong) -> c_int { -1 }
#[no_mangle] pub extern "C" fn CloseStream(_id: c_longlong) {}
#[no_mangle] pub extern "C" fn CloseStreamInput(_id: c_longlong) {}
#[no_mangle] pub extern "C" fn StreamReady(_id: c_longlong) {}
#[no_mangle] pub extern "C" fn CacheGet(_s: *mut c_char, _k: *mut c_char) -> FfiData { FfiData { data: ptr::null_mut(), len: 0 } }
#[no_mangle] pub extern "C" fn CachePut(_s: *mut c_char, _k: *mut c_char, _d: *mut c_void, _l: c_longlong, _t: c_longlong) -> c_int { -1 }
#[no_mangle] pub extern "C" fn CacheContains(_s: *mut c_char, _k: *mut c_char) -> c_int { -1 }
#[no_mangle] pub extern "C" fn CacheDelete(_s: *mut c_char, _k: *mut c_char) -> c_int { -1 }

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
