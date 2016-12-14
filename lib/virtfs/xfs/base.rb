module VirtFS::XFS
  class FS
    module Base
      # Default index cache size
      DEF_CACHE_SIZE = 500

      attr_accessor :mount_point, :superblock, :root_dir, :entry_cache, :cache_hits, :dir_cache

      def self.match?(blk_device)
        begin
          # The first Allocation Group's Superblock is at block zero.
          blk_device.seek(0, IO::SEEK_SET)
          VirtFS::XFS::Superblock.new(blk_device)

          # If initialize the superblock does not throw any errors, then this is XFS
          return true
        rescue
          return false
        ensure
          blk_device.seek(0, IO::SEEK_SET)
        end
      end

      def initialize(blk_device)
        blk_device.seek(0, IO::SEEK_SET)
        @superblock  = Superblock.new(blk_device)
        @fs_id       = superblock.filesystem_id.to_s
        @volName     = superblock.volume_name
        @root_dir    = Directory.new(superblock, superblock.root_inode)
        @mount_point = nil

        # Initialize cache
        @entry_cache = LruHash.new(DEF_CACHE_SIZE)
        @dir_cache   = LruHash.new(DEF_CACHE_SIZE)
        @cache_hits  = 0
      end

      def thin_interface?
        true
      end

      def umount
        @mount_point = nil
      end

      def unnormalize_path(p)
        p[1] == 58 ? p[2, p.size] : p
      end
    end # module Base
  end   # class FS
end     # module VirtFS::XFS
