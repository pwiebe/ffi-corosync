
require 'libcorosync'

module FFICorosync
  extend FFI::Library
  ffi_lib "corosync.so"

  ## CGP library

  attach_function :cgp_initialize



end
