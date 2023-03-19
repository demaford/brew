# typed: true
# frozen_string_literal: true

module RuboCop
  module Cop
    module Cask
      class NoOverrides < Base
        extend T::Sig
        include CaskHelp

        ON_SYSTEM_METHODS = RuboCop::Cask::Constants::ON_SYSTEM_METHODS
        MESSAGE = <<~EOS
          Do not use top-level `%<stanza>s` stanza as the default, add an `on_{system}` block instead.
          Use `:or_older` or `:or_newer` to specify a range of macOS versions.
        EOS

        def on_cask(cask_block)
          return if (cask_stanzas = cask_block.toplevel_stanzas).empty?
          # Skip if there are no `on_*` blocks.
          return unless cask_stanzas.any? { |s| ON_SYSTEM_METHODS.include?(s.stanza_name) }

          cask_stanzas.each do |stanza|
            # TODO: We probably only want to disallow `version`, `url`, and `sha256` stanzas being overridden?
            next unless RuboCop::Cask::Constants::STANZA_ORDER.include?(stanza.stanza_name)
            # Skip if the stanza we detect is already in an `on_*` block.
            next if stanza.parent_node.block_type? && ON_SYSTEM_METHODS.include?(stanza.parent_node.method_name)

            add_offense(stanza.source_range, message: format(MESSAGE, stanza: stanza.stanza_name))
          end
        end
      end
    end
  end
end
