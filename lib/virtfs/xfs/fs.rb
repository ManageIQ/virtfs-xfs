module VirtFS::XFS
  class FS
    include FS::Base
    include FS::FileMethods
    include FS::DirMethods
  end # class FS
end   # module VirtFS::XFS
