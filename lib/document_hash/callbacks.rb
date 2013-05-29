module DocumentHash
  class Core
    def after_change &block
      @after_change = block
    end
  end
end
