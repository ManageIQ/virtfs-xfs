module VirtFS::XFS
  class DirectoryBlockTail
    #
    # xfs_dir2_data_hdr consists of the magic number
    # followed by 3 copies of the xfs_dir2_data_free structure
    #
    TAIL = BinaryStruct.new([
      'I>', 'count',               # total number of leaf entries
      'I>', 'stale',               # total number of free entries
    ])
    SIZEOF_TAIL = TAIL.size

    attr_reader :count, :stale, :size

    def initialize(data)
      tail   = TAIL.decode(data)
      @count = tail['count']
      @stale = tail['stale']
      @size  = SIZEOF_TAIL
    end
  end # class DirectoryBlockTail
end   # module VirtFS::XFS
