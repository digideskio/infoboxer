# encoding: utf-8
require 'htmlentities'

module Infoboxer
  class Node
    include ProcMe
    
    def initialize(params = {})
      @params = params
    end

    attr_reader :params
    attr_accessor :parent

    def ==(other)
      self.class == other.class && _eq(other)
    end

    def index
      parent ? parent.index_of(self) : 0
    end

    def siblings
      parent ? parent.children - [self] : Nodes[]
    end

    def children
      Nodes[]
    end

    def prev_siblings
      siblings.select{|n| n.index < index}
    end

    def next_siblings
      siblings.select{|n| n.index > index}
    end
    
    def can_merge?(other)
      false
    end

    def empty?
      false
    end

    def to_tree(level = 0)
      indent(level) + "<#{descr}>\n"
    end

    def inspect
      text.empty? ? "#<#{descr}>" : "#<#{descr}: #{shorten_text}>"
    end

    def text
      ''
    end

    def text_
      text.strip
    end

    # just aliases will not work when #text will be redefined in subclasses
    def to_s
      text
    end

    private

    MAX_CHARS = 30

    def shorten_text
      text.length > MAX_CHARS ? text[0..MAX_CHARS] + '...' : text
    end

    def clean_class
      self.class.name.sub(/^.*::/, '')
    end

    def descr
      if !params || params.empty?
        "#{clean_class}"
      else
        "#{clean_class}(#{show_params})"
      end
    end

    def show_params(prms = nil)
      (prms || params).map{|k, v| "#{k}: #{v.inspect}"}.join(', ')
    end

    def indent(level)
      '  ' * level
    end

    def _eq(other)
      fail(NotImplementedError, "#_eq should be defined in subclasses")
    end

    def decode(str)
      Node.coder.decode(str)
    end
    
    class << self
      def def_readers(*keys)
        keys.each do |k|
          define_method(k){ params[k] }
        end
      end

      def coder
        @coder ||= HTMLEntities.new
      end
    end
  end
end

require_relative 'node/text'
require_relative 'node/compound'
require_relative 'node/inline'
require_relative 'node/image'
require_relative 'node/html'
require_relative 'node/paragraphs'
require_relative 'node/list'
require_relative 'node/template'
require_relative 'node/table'
require_relative 'node/ref'
