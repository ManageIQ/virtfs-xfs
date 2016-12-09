module VirtFS::XFS
  class File
    def initialize(dir_entry, superblock)
      @bs = superblock
      @de = dir_entry
    end

    def to_h
      { :directory? => @de.dir?,
        :file?      => @de.file?,
        :symlink?   => @de.symlink? }
    end
  end # class File
end   # module VirtFS::XFS
