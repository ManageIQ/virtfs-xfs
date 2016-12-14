module VirtFS::XFS
  class FS
    module DirMethods
      def dir_delete(p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS."
      end

      def dir_entries(p)
        dir = get_dir(p)
        return nil if dir.nil?
        dir.glob_names
      end

      def dir_exist?(p)
        begin
          !get_dir(p).nil?
        rescue
          false
        end
      end

      def dir_foreach(p, &block)
        r = get_dir(p).try(:glob_names).try(:each, &block)
        block.nil? ? r : nil
      end

      def dir_mkdir(p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS."
      end

      def dir_new(fs_rel_path, _hash_args = {}, _open_path = nil, _cwd = nil)
        get_dir(fs_rel_path)
      end

      def dir_rmdir(p)
        raise "VirtFS::XFS Write functionality is not yet supported on XFS."
      end

      private

      def get_dir(p)
        # Wack leading drive.
        p = unnormalize_path(p)

        # Get an array of directory names, kill off the first (it's always empty).
        names = p.split(/[\\\/]/)
        names.shift

        dir = get_dir_r(names)
        raise "VirtFS::XFS Directory '#{p}' not found" if dir.nil?
        dir
      end

      def get_dir_r(names)
        return root_dir if names.empty?

        # Check for this path in the cache.
        fname = names.join('/')
        if dir_cache.key?(fname)
          cache_hits += 1
          return dir_cache[fname]
        end

        name = names.pop
        pdir = get_dir_r(names)
        return nil if pdir.nil?

        de = pdir.find_entry(name, VirtFS::XFS::Inode::FT_DIRECTORY)
        return nil if de.nil?
        entry_cache[fname] = de

        dir = Directory.new(superblock, de.inode)
        return nil if dir.nil?

        dir_cache[fname] = dir
      end
    end # module DirMethods
  end   # class FS
end     # module VirtFS::XFS
