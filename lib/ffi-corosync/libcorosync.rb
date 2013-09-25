
require 'ffi'

module LibCorosync
  extend FFI::Library

  COROSYNC_LIBS = ["libcorosyc_common", "libcpg"].map { |l| "#{l}.#{FFI::Platform::LIBSUFFIX}"}
  ffi_lib COROSYNC_LIBS # TODO: there are multiple libraries for corosync...

  typedef(:long, :size_t)

  ## Generic typedefs/enums
    #typedef enum {
    #   CS_OK = 1,
    #   CS_ERR_LIBRARY = 2,
    #   CS_ERR_VERSION = 3,
    #   CS_ERR_INIT = 4,
    #   CS_ERR_TIMEOUT = 5,
    #   CS_ERR_TRY_AGAIN = 6,
    #   CS_ERR_INVALID_PARAM = 7,
    #   CS_ERR_NO_MEMORY = 8,
    #   CS_ERR_BAD_HANDLE = 9,
    #   CS_ERR_BUSY = 10,
    #   CS_ERR_ACCESS = 11,
    #   CS_ERR_NOT_EXIST = 12,
    #   CS_ERR_NAME_TOO_LONG = 13,
    #   CS_ERR_EXIST = 14,
    #   CS_ERR_NO_SPACE = 15,
    #   CS_ERR_INTERRUPT = 16,
    #   CS_ERR_NAME_NOT_FOUND = 17,
    #   CS_ERR_NO_RESOURCES = 18,
    #   CS_ERR_NOT_SUPPORTED = 19,
    #   CS_ERR_BAD_OPERATION = 20,
    #   CS_ERR_FAILED_OPERATION = 21,
    #   CS_ERR_MESSAGE_ERROR = 22,
    #   CS_ERR_QUEUE_FULL = 23,
    #   CS_ERR_QUEUE_NOT_AVAILABLE = 24,
    #   CS_ERR_BAD_FLAGS = 25,
    #   CS_ERR_TOO_BIG = 26,
    #   CS_ERR_NO_SECTIONS = 27,
    #   CS_ERR_CONTEXT_NOT_FOUND = 28,
    #   CS_ERR_TOO_MANY_GROUPS = 30,
    #   CS_ERR_SECURITY = 100
    #} cs_error_t;

  enum :cs_error_t, [:cs_ok, 1, :cs_err_library, :cs_err_version, :cs_err_init, :cs_err_timeout, :cs_err_try_again,
                     :cs_err_invalid_param, :cs_err_no_memory, :cs_err_bad_handle, :cs_err_busy, :cs_err_access,
                     :cs_err_not_exist, :cs_err_name_too_long, :cs_err_exist, :cs_err_no_space, :cs_err_interrupt,
                     :cs_err_name_not_found, :cs_err_no_resources, :cs_err_not_supported, :cs_err_bad_operation,
                     :cs_err_failed_operation, :cs_err_message_error, :cs_err_queue_full, :cs_err_queue_not_available,
                     :cs_err_bad_flags, :cs_err_too_big, :cs_err_no_sections, :cs_err_context_not_found,
                     :cs_err_too_many_groups, :cs_err_security, 100]

  ## CGP library

  typedef(:uint64, :cpg_handle_t)
  typedef(:uint64, :cpg_iteration_handle_t)

  enum :cpg_guarantee_t, [:cpg_type_unordered, :cpg_type_fifo, :cpg_type_agreed, :cpg_type_safe]
  enum :cpg_flow_control_state_t, [:cpg_flow_control_disabled, :cpg_flow_control_enabled]
  enum :cpg_reason_t, [:cpg_reason_join, 1, :cpg_reason_leave, :cpg_reason_nodedown, :cpg_reason_nodeup, :cpg_reason_procdown]
  enum :cpg_iteration_type_t, [:cpg_iteration_name_only, 1, :cpg_iteration_one_group, :cpg_iteration_all]
  enum :cpg_model_t, [:cpg_model_v1]

  class CpgAddress < FFI::Struct
    layout :nodeid => :uint32,
           :pid => :uint32,
           :reason => :uint32
  end

  CPG_MAX_NAME_LENGTH = 128.freeze
  class CpgName < FFI::Struct
    layout :length => :uint32,
           :value => [:char, CPG_MAX_NAME_LENGTH]  # char value[CPG_MAX_NAME_LENGTH]
  end

  CPG_MEMBERS_MAX = 128.freeze
  class CgpIterationDescription < FFI::Struct
    layout :cpg_name => CpgName,
           :nodeid => :uint32,
           :pid => :uint64
  end

  class CpgRingId < FFI::Struct
    layout :nodeid => :uint32,
           :seq => :uint64
  end

  #typedef void (*cpg_deliver_fn_t) (
  #  cpg_handle_t handle,
  #  const struct cpg_name *group_name,
  #  uint32_t nodeid,
  #  uint32_t pid,
  #  const void *msg,
  #  size_t msg_len);

  callback :cpg_deliver_fn_t, [:cpg_handle_t, :pointer, :uint32, :uint32, :pointer, :size_t], :void

  #typedef void (*cpg_confchg_fn_t) (
  #  cpg_handle_t handle,
  #  const struct cpg_name *group_name,
  #  const struct cpg_address *member_list, size_t member_list_entries,
  #  const struct cpg_address *left_list, size_t left_list_entries,
  #  const struct cpg_address *joined_list, size_t joined_list_entries);
  #
  callback :cpg_confchg_fn_t, [:cpg_handle_t, :pointer, :size_t, :pointer, :size_t, :pointer, :size_t], :void

  #typedef struct {
  #  cpg_deliver_fn_t cpg_deliver_fn;
  #  cpg_confchg_fn_t cpg_confchg_fn;
  #} cpg_callbacks_t;

  class CpgCallbacks < FFI::Struct
    layout :cpg_deliver_fn => :cpg_confchg_fn_t,
           :cpg_confchg_fn => :cpg_confchg_fn_t
  end

  # cpg_handle_t *, cpg_callbacks_t *
  attach_function :cpg_initialize, [:pointer, :pointer], :int

  # TODO:
  attach_function :cpg_model_initialize, [], :int

  # cpg_handle_t
  attach_function :cpg_finalize, [:cpg_handle_t], :int

  #typedef enum {
  #  CS_DISPATCH_ONE,
  #  CS_DISPATCH_ALL,
  #  CS_DISPATCH_BLOCKING
  #} cpg_dispatch_t;

  # cpg_handle_t handle, cpg_dispatch_t *dispatch_types
  attach_function :cpg_dispatch, [:cpg_handle_t, :pointer], :int

  # cpg_handle_t handle, int *fd
  attach_function :cpg_fd_get, [:cpg_handle_t, :pointer], :int

  # cpg_handle_t, struct cpg_name *
  attach_function :cpg_join, [:cpg_handle_t, :pointer], :int

  # cpg_handle_t, struct cpg_name *
  attach_function :cpg_leave, [:cpg_handle_t, :pointer], :int

  # cpg_handle_t handle, cpg_guarantee_t guarantee, struct iovec *iovec, int iov_len
  attach_function :cpg_mcast_joined, [:cpg_handle_t, :int, :pointer, :int], :int

  # cpg_handle_t handle, struct cpg_name *groupName, struct cpg_address *member_list, int *member_list_entries
  attach_function :cpg_membership_get, [:cpg_handle_t, :pointer, :pointer, :pointer], :int

  #attach_function :cpg_local_get



end
