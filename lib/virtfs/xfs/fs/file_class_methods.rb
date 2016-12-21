module VirtFS::XFS
  class FS
    module FileClassMethods

      def file_atime(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        superblock.inode(de.inode).access_time
      end

      def file_blockdev?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).mode_set?(VirtFS::Inode::FM_BLOCK_DEV)
      end

      def file_chardev?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).mode_set?(VirtFS::Inode::FM_CHAR)
      end

      def file_chmod(_permission, _p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_chown(_owner, _group, _p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_ctime(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        superblock.inode(de.inode).create_time
      end

      def file_delete(_p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_directory?(p)
        de = get_file(p)
        return false if de.nil?
        de.directory?
      end

      def file_executable?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).owner_permissions && VirtFS::Inode::PF_O_EXECUTE ||
        superblock.inode(de.inode).group_permissions && VirtFS::Inode::PF_G_EXECUTE ||
        superblock.inode(de.inode).user_permissions  && VirtFS::Inode::PF_U_EXECUTE
      end

      def file_executable_real?(p)
      end

      def file_exist?(p)
        !get_file(p).nil?
      end

      def file_file?(p)
        de = get_file(p)
        !de.nil? && de.file?
      end

      def file_ftype(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
      end

      def file_lchmod(_permission, _p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_lchown(_owner, _group, _p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_link(_p1, _p2)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_lstat(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        VirtFS::Stat.new(VirtFS::XFS::File.new(de, superblock).to_h)
      end

      def file_mtime(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        superblock.inode(de.inode).modification_time
      end

      def file_new(p, parsed_args, _open_path, _cwd)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        de
      end

      def file_pipe?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).mode_set?(VirtFS::Inode::FM_FIFO)
      end

      def file_readable?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).owner_permissions && VirtFS::Inode::PF_O_READ ||
        superblock.inode(de.inode).group_permissions && VirtFS::Inode::PF_G_READ ||
        superblock.inode(de.inode).user_permissions  && VirtFS::Inode::PF_U_READ
      end

      def file_readable_real?(p)
      end

      def file_readlink(p)
      end

      def file_rename(_p1, _p2)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_setgid?(p)
      end

      def file_setuid?(p)
      end

      def file_size(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        superblock.inode(de.inode).length
      end

      def file_socket?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).mode_set?(VirtFS::Inode::FM_SOCKET)
      end

      def file_stat(p)
      end

      def file_sticky?(p)
        de = get_file(p)
        return false if de.nil?
        # superblock.inode(de.inode).mode_set?(VirtFS::Inode::FM_SOCKET)
      end

      def file_symlink(_oname, _p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_symlink?(p)
        de = get_file(p)
        raise Errno::ENOENT, "No such file or directory #{p}" if de.nil?
        de.symlink?
      end

      def file_write(_fobj, _buf, _len)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_truncate(_p, _len)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS"
      end

      def file_utime(atime, mtime, p)
      end

      def file_world_readable?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).owner_permissions && VirtFS::Inode::PF_U_READ
      end

      def file_world_writeable?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).owner_permissions && VirtFS::Inode::PF_U_WRITE
      end

      def file_writeable?(p)
        de = get_file(p)
        return false if de.nil?
        superblock.inode(de.inode).owner_permissions && VirtFS::Inode::PF_O_WRITE ||
        superblock.inode(de.inode).group_permissions && VirtFS::Inode::PF_G_WRITE ||
        superblock.inode(de.inode).user_permissions  && VirtFS::Inode::PF_U_WRITE
      end

      def file_writeable_real?(p)
      end

      private

      # Return a DirectoryEntry for a given file or nil if it does not exist
      def get_file(p)
        # Preprocess path
        p = unnormalize_path(p)
        dir, file_name = File.split(p)
        # Fix for FB#835: if file_name == root then file_name needs to be "."
        file_name = "." if file_name == "/" || file_name == "\\"

        # Check for this file in the cache
        cache_name = "#{dir == '/' ? '' : dir}/#{file_name}"
        if entry_cache.key?(cache_name)
          return entry_cache[cache_name]
        end

        # Look for file in dir, but don't error if it doesn't exist.
        # NOTE: if p is a directory that's ok, find it.
        begin
          directory_object = get_dir(dir)
          directory_entry = directory_object.nil? ? nil : directory_object.find_entry(file_name)
        rescue RuntimeError
          directory_entry = nil
        end

        entry_cache[cache_name] = directory_entry
      end
    end # module FileClassMethods
  end   # class FS
end     # module VirtFS::XFS
