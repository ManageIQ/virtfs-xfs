module VirtFS::XFS
  #
  # Handle the BTree Root Node in the Disk Inode
  #
  class BmapBTreeRootNode
    HEADER = BinaryStruct.new([
      'S>',          'level',           # B+Tree Level
      'S>',          'entry_count',     # Number of Key and Pointer Array Elements
    ])

    SIZEOF_HEADER = HEADER.size

    #
    # Note that the following 3 entries are used simply to compute the maximum
    # number of records possible in the on-disk inode.
    #
    ENTRIES = BinaryStruct.new([
      'Q>',          'starting_offset', # starting offset of the block
      'Q>',          'block_number',    # block number of the entry
    ])
    SIZEOF_ENTRIES = ENTRIES.size

    OFFSET = BinaryStruct.new([
      'Q>',          'starting_offset',  # starting offset of the block
    ])
    SIZEOF_OFFSET = OFFSET.size

    BLOCK = BinaryStruct.new([
      'Q>',          'block_number',     # block number of the entry
    ])
    SIZEOF_BLOCK = BLOCK.size

    attr_accessor   :level, :entry_count, :blocks

    def initialize(data, inode)
      raise "VirtFS::XFS::BmapBTreeRootNode: Nil buffer" if data.nil?
      @inode       = inode
      @header      = HEADER.decode(data[0..inode.length])
      @level       = @header['level']
      @entry_count = @header['entry_count']
      raise "VirtFS::XFS::BmapBTreeRootNode: Invalid Root Node Level" if @level.nil? || @level == 0
      header_size = SIZEOF_HEADER
      return if @entry_count == 0
      #
      # The Root Node contains an array of starting offsets followed by
      # an array of block numbers.  While only the required number of entries
      # are initialized, there is space left for the maximum number of entries
      # that may fit in the disk inode data fork (eliminating any space taken
      # up by extended attributes).
      # We only care about the block numbers.  The offsets of individual data blocks are
      # also kept in the BmapBTreeRecord
      #
      fork_size       = @inode.dfork_size(Inode::XFS_DATA_FORK)
      maximum_records = (fork_size - header_size) / SIZEOF_ENTRIES
      return if maximum_records == 0
      @blocks     = []
      offset_size = SIZEOF_OFFSET
      block_size  = SIZEOF_BLOCK
      size        = SIZEOF_HEADER
      1.upto(@entry_count) do |i|
        start      = size + maximum_records * offset_size + (i - 1) * block_size
        block      = (data[start..start + block_size]).unpack('Q>').shift
        agbno      = inode.sb.fsb_to_agbno(block)
        agno       = inode.sb.fsb_to_agno(block)
        real_block = inode.sb.agbno_to_real_block(agno, agbno)
        @blocks.concat([real_block])
      end
    end
  end
end
