module VirtFS::XFS
  class FS
    include FS::Base
    include FS::File
    include FS::FileClassMethods
    include FS::DirClassMethods
  end # class FS
end   # module VirtFS::XFS
