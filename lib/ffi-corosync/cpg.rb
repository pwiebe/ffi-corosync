module Corosync
  class Cpg

    # TODO: ObjectSpace.finalizer( LibCorosync.finalize(@handle) )

    def initialize(deliver_cb, confchg_cb)

      # TODO: validate arity of callbacks
      @deliver_cb = deliver_cb
      @confchg_cb = confchg_cb
      @handle_ptr = FFI::MemoryPointer.new LibCorosync.find_type(:cpg_handle_t)
      #typedef void (*cpg_deliver_fn_t) (
      #  cpg_handle_t handle,
      #  const struct cpg_name *group_name,
      #  uint32_t nodeid,
      #  uint32_t pid,
      #  const void *msg,
      #  size_t msg_len);
      @cpg_deliver_cb = Proc.new do |handle, group_name_ptr, nodeid, pid, msg_ptr, msg_len|
        @deliver_cb.call(group_name, nodeid, pid, msg)
      end

      #typedef void (*cpg_confchg_fn_t) (
      #  cpg_handle_t handle,
      #  const struct cpg_name *group_name,
      #  const struct cpg_address *member_list, size_t member_list_entries,
      #  const struct cpg_address *left_list, size_t left_list_entries,
      #  const struct cpg_address *joined_list, size_t joined_list_entries);
      #
      @cpg_confchg_cb = Proc.new do |handle, group_name_ptr, member_ptr, num_members, left_ptr, num_left, joined_ptr, num_joined|
        @confchg_cb.call(group_name, members, left, joined)
      end

      callbacks = LibCorosync::CpgCallbacks.new
      callbacks[:cpg_deliver_fn] = @cpg_confchg_cb
      callbacks[:cpg_confchg_fn] = @confchg_cb

      ret = LibCorosync.cpg_initialize(@handle_ptr, @callbacks)
      puts "#{self.class}: ret=#{ret}  #{@handle_ptr}"
      self
    end

    def join(name)
      #cpg_name =  FFI::MemoryPointer.new(name.length)
      #cpg_name.put_string(0, name)
      cpg_name =  FFI::MemoryPointer.from_string(name)
      ret = LibCorosync.cpg_join(@handle, cpg_name)
      ret
    end

    def leave(name)
      #cpg_name =  FFI::MemoryPointer.new(name.length)
      #cpg_name.put_string(0, name)
      cpg_name =  FFI::MemoryPointer.from_string(name)
      ret = LibCorosync.cpg_leave(@handle, cpg_name)
      ret
    end

  end
end