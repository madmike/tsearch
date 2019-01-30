module TSearch
  module Document
    extend ActiveSupport::Concern

#       included do
#
#       end
    attr_accessor :arguments

    def initialize(hash, persisted = false)
      @arguments = hash.symbolize_keys
      @persisted = persisted

      @arguments.each do |key, val|
        unless respond_to? key
          self.class.send(:define_method, key.to_sym) do
            @arguments[key]
          end
        end

        unless respond_to? (key.to_s+'=')
          self.class.send(:define_method, (key.to_s+'=').to_sym) do |v|
            @arguments[key.to_sym] = v
          end
        end
      end
    end

    # def method_missing(m, *args, &block)
    #   @arguments[m.to_sym] if @arguments.key? m.to_sym
    # end

    def update_arguments(arguments)
      Client.put("topics/#{id}", arguments)
    end

    def new?
      !@persisted
    end

    def persisted?
      @persisted
    end

    def to_s
      @arguments.to_s
    end

    module ClassMethods
      def find(id, options = {})
        res = Client.get("topics/#{id}")
        #res.map { |name, id| self.new({id: id, name: name}, true) }.first
        res['children'] ||= []
#        keywords = Client.get("topics/#{id}/keywords")
#        res['keywords'] = keywords
        self.new(res, true)
      end

      def all(options = {})
        res = Client.get('topics')
        col = res&.map { |topic| topic['children_ids'] ||= []; self.new(topic, true) } || []

        Collection.new(col)
      end

      def objects(id, options = {})
        res = Client.get("objects/#{id}", {method: 1})
        col = res&.dig('topics')&.map { |topic| self.new(topic, true) } || []

        return Collection.new(col), res&.dig('object_ids') || []
      end

      def find_by_text(text)
        res = Client.post('objects/search', text: text, method: 1)
        col = res&.dig('topics')&.map { |topic| self.new(topic, true) } || []

        return Collection.new(col), res&.dig('object_ids') || []
      end

      def add_collection(id)
        res = Client.post('collections', collection_id: id)
      end

      def delete_collection(id)
        res = Client.delete("collections/#{id}")
      end

      def add_object_to_collection(col_id, obj_id)
        res = Client.post("collections/#{col_id}/objects", object_id: obj_id)
      end

      def delete_object_from_collection(col_id, obj_id)
        res = Client.delete("collections/#{col_id}/objects/#{obj_id}")
      end

      def get_ranked_objects(col_id)
        res = Client.get("collections/#{col_id}/ranked_objects")

        res && res['object_ids']
      end

      def versions(obj_id)
        res = Client.get("versions/#{obj_id}")

        res && res['object_ids']
      end
    end
  end
end
