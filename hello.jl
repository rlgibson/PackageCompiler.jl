# hello.jl
using Libdl

global_store = []
hello = "hello"
docstring = "A hello module"

const Py_ssize_t = Clong

mutable struct PyObject
    ob_refcnt::Py_ssize_t
    ob_type::Ptr{Cvoid}
end

const PtrPyObject = Ptr{PyObject} # type for PythonObject* in ccall

mutable struct PyMethodDef
    ml_name::Ptr{Cvoid}
    ml_meth::Ptr{Cvoid} # PyCFunctionWithKeywords
    ml_flags::Cint
    ml_doc::Ptr{Cvoid}
end

mutable struct PyModuleDef_Base
    ob_base::PyObject
    m_init::Ptr{Cvoid} # pointer to function
    m_index::Py_ssize_t
    m_copy::Ptr{Cvoid} # PtrPyObject
end

mutable struct PyModuleDef_Slot
    slot::Cint
    value::Ptr{Cvoid}
end

mutable struct PyModuleDef
    ob_refcnt::Py_ssize_t
    ob_type::Ptr{Cvoid}
    m_init::Ptr{Cvoid} # pointer to function
    m_index::Py_ssize_t
    m_copy::Ptr{Cvoid} # PtrPyObject
    m_name::Cstring
    m_doc::Cstring
    m_size::Py_ssize_t
    m_methods::Ptr{PyMethodDef}
    m_slots::Ptr{Cvoid}
    m_traverse::Ptr{Cvoid}
    m_clear::Ptr{Cvoid}
    m_free::Ptr{Cvoid}
end

method = PyMethodDef(Ptr{Cvoid}(), Ptr{Cvoid}(), 0, Ptr{Cvoid}())

function createPyModuleDef()
    m = PyModuleDef(
        1,
        Ptr{Cvoid}(),
        Ptr{Cvoid}(),
        0,
        Ptr{Cvoid}(),
        Cstring(pointer(hello)),
        Cstring(pointer(docstring)),
        -1,
        pointer_from_objref(method),
        Ptr{Cvoid}(),
        Ptr{Cvoid}(),
        Ptr{Cvoid}(),
        Ptr{Cvoid}(),
    )
    return m
end

Base.@ccallable function PyInitHello()::Ptr{Cvoid}
    lib = ccall(:jl_dlopen, Ptr{Cvoid}, (Ptr{Cvoid}, UInt32), C_NULL, 0)
    m = createPyModuleDef()
    PyModule_Create2 = dlsym(lib, :PyModule_Create2)
    ppymodule = ccall(PyModule_Create2, Ptr{PyObject}, (Ptr{PyModuleDef}, Int), Ref(m), 3)
    return ppymodule
end
