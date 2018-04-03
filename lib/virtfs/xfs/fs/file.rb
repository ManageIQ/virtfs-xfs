module VirtFS::XFS
  class FS
    class File
      attr_reader :fs, :file_obj, :block_size

      def initialize(fs, instance_handle, parsed_args)
        @fs            = fs
	@file_obj      = self
	@inode         = superblock.inode(instance_handle.inode)
        @parsed_args   = parsed_args
        @block_size    = 512
        @close_on_exec = nil
      end

      def atime
        @inode.access_time
      end

      def chmod(_permission)
	raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def chown(_owner, _group)
	raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def close
      end

      def close_on_exec?
        @file_obj.close_on_exec?
      end

      def close_on_exec=(bool)
        @file_obj.close_on_exec = bool
      end

      def close_read
      end

      def close_write
      end

      def ctime
        @inode.create_time
      end

      def fcntl(cmd, arg)
      end

      def fdatasync
      end

      def fileno
        @file_obj.fileno
      end

      def flock(locking_constant)
      end

      def flush
      end

      def fsync
      end

      def isatty
        @file_obj.isatty
      end

      def lstat
        @file_obj.lstat
      end

      def mtime
        @inode.modification_time
      end

      def pid
      end

      def raw_read(start_byte, num_bytes)
      end

      def raw_write(_start_byte, _buf)
	raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def size
        @inode.length
      end

      def stat
        @file_obj.stat
      end

      def truncate(len)
	raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end
    end # module File
  end   # class FS
end     # module VirtFS::XFS
