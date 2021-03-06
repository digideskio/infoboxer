# encoding: utf-8
require_relative 'linkable'

module Infoboxer
  module Tree
    # Internal MediaWiki link class.
    #
    # See [Wikipedia docs](https://en.wikipedia.org/wiki/Help:Link#Wikilinks)
    # for extensive explanation of Wikilink concept.
    #
    # Note, that Wikilink is {Linkable}, so you can {Linkable#follow #follow}
    # it to obtain linked pages.
    class Wikilink < Link
      def initialize(*)
        super
        parse_link!
      end

      # "Clean" wikilink name, for ex., `Cities` for `[Category:Cities]`
      attr_reader :name

      # Wikilink namespace, `Category` for `[Category:Cities]`, empty
      # string (not `nil`!) for just `[Cities]`
      attr_reader :namespace

      # Anchor part of hyperlink, like `History` for `[Argentina#History]`
      attr_reader :anchor

      # Topic part of link name.
      #
      # There's so-called ["Pipe trick"](https://en.wikipedia.org/wiki/Help:Pipe_trick)
      # in wikilink markup, which defines that `[Phoenix, Arizona]` link
      # has main part ("Phoenix") and refinement part ("Arizona"). So,
      # we are splitting it here in `topic` and {#refinement}.
      # The same way, `[Pipe (programming)]` has `topic == 'Pipe'` and
      # `refinement == 'programming'`
      attr_reader :topic
      
      # Refinement part of link name.
      #
      # See {#topic} for explanation.
      attr_reader :refinement

      include Linkable

      private

      def parse_link!
        @name, @namespace = link.split(':', 2).reverse
        @namespace ||= ''

        @name, @anchor = @name.split('#', 2)
        @anchor ||= ''

        parse_topic!
      end

      # @see http://en.wikipedia.org/wiki/Help:Pipe_trick
      def parse_topic!
        @topic, @refinement = case @name
          when /^(.+\S)\s*\((.+)\)$/,
               /^(.+?),\s*(.+)$/
            [$1, $2]
          else
            [@name, '']
          end

        if children.count == 1 && children.first.is_a?(Text) && children.first.raw_text.empty?
          children.first.raw_text = @topic
        end
      end
    end
  end
end
