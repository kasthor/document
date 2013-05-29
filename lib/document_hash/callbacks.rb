module DocumentHash
  class Core
    def after_change &block
      @after_change = block
    end

    def before_change &block
      @before_change = block
    end
  end
end
