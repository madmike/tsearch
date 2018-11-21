module TSearch
  class Collection
    include Enumerable
    @members = []

    def initialize(array)
      @members = array
    end

    def each(&block)
      @members.each do |member|
        block.call(member)
      end
    end
  end
end
