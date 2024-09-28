# frozen_string_literal: true

require 'cgi'

module AsciidoctorLaTexCore

	class LaTexCoreConverter < Asciidoctor::Converter::Base
		register_for 'latexcore'

		LF = "\n"

		IGNORED_SCOPES = Set[
			# Built-in roles
			'underline', 'overline', 'line-through', 'nobreak', 'nowrap', 'pre-wrap',
			# Common roles
			'right'
		]

		def initialize backend, opts = {}
			@backend = backend
			init_backend_traits basebackend: 'latexcore', filetype: 'tex', outfilesuffix: '.tex', supports_templates: true
		end

		def convert_document node
			tex_root = node.attr 'texroot'

			# root name
			result = []
			result << %(\
\%!TEX root = #{tex_root}
) if tex_root

			# section 0
			result << %(\
\% #{node.title.strip}
\\rSec#{node.level}[#{node.reftext}]{#{node.title.strip}}
)

			# content
			result << %(\
#{node.content})

			result.join LF
		end

		def convert_embedded node
			result = []
			result << %(\
#{node.content})
			result.join LF
		end

		def convert_section node
			result = []
			result << %(\
\% #{node.title.strip}
\\rSec#{node.level}[#{node.reftext}]{#{node.title.strip}}
)
			result << %(\
#{node.content})
			result.join LF
		end

		def convert_admonition node
			result = []
			result.join LF
		end

		def convert_colist node
			result = []
			result.join LF
		end

		def convert_dlist node
			result = []
			result.join LF
		end

		def convert_example node
			result = []
			result.join LF
		end

		def convert_floating_title node
			result = []
			result.join LF
		end

		def convert_image node
			result = []
			result.join LF
		end

		def convert_listing node
			result = []
			result.join LF
		end

		def convert_literal node
			result = []
			result.join LF
		end

		def convert_sidebar node
			result = []
			result.join LF
		end

		def convert_olist node
			result = []
			result.join LF
		end

		def convert_open node
		end

		def convert_page_break node
			'\\newpage\n'
		end

		def convert_paragraph node
			result = []
			if node.role == 'itemdescr'
				result << %(
\\begin{itemdescr}
#{texify(node.content)}
\\end{itemdescr}
)
			else
				result << %(\
\\pnum
#{texify(node.content)}
)
			end
			result.join LF
		end

		alias convert_pass content_only
		alias convert_preamble content_only

		def convert_quote node
			result = []
			result.join LF
		end

		def convert_stem node
			result = []
			result.join LF
		end

		def convert_table node
			result = []
			result.join
		end

		def convert_thematic_break node
		end

		alias convert_toc skip

		def convert_ulist node
			result = []
			result.join LF
		end

		def convert_verse node
			result = []
			result.join LF
		end

		alias convert_video skip

		def convert_inline_anchor node
			target = node.target
			case node.type
			when :xref
				unless (text = node.text)
					if AbstractNode === (ref = (@refs ||= node.document.catalog[:refs])[refid = node.attributes['refid']] || (refid.nil_or_empty? ? (top = get_root_document node) : nil))
						if (@resolving_xref ||= (outer = true)) && outer && (text = ref.xreftext node.attr 'xrefstyle', nil, true)
							text = text if ref.context === :section && ref.level < 2 && text == ref.title
						else
							text = top ? nil : %(\\iref{#{refid}})
						end
						@resolving_xref = nil if outer
					else
						text = %(\\iref{#{refid}})
					end
				end
				text
			else
				logger.warn %(unknown anchor type: #{node.type.inspect})
				nil
			end
		end

		def convert_inline_break node
			%(#{node.text})
		end

		alias convert_inline_button skip

		def convert_inline_callout node
			%(#{node.text})
		end

		def convert_inline_footnote node
			%(#{node.text})
		end

		alias convert_inline_image skip

		def convert_inline_indexterm node
			node.type == :visible ? texify(node.text) : ''
		end

		def convert_inline_kbd node
		end

		def convert_inline_menu node
		end

		def convert_inline_quoted node
			case node.type
			when :emphasis
				%(\\emph{#{texify(node.text)}})
			when :strong
				%(<\\textbf{#{texify(node.text)}})
			when :monospaced
				%[\\verb{#{texify(node.text)}}]
			when :single
				texify(node.text)
			when :double
				texify(node.text)
			else
				if node.role && IGNORED_SCOPES.include?(node.role)
					nil
				elsif node.role
					case node.role
					when 'iref'
						%(\\#{node.role}{#{texify(node.text).sub(/^\(\[/,'').sub(/\]\)$/,'')}})
					when 'fldname'
						%(\\pnum \\fldname)
					when 'fldtype'
						%(\\pnum \\fldtype)
					when 'fldval'
						%(\\pnum \\fldval)
					when 'flddesc'
						%(\\pnum \\flddesc)
					else
						%(\\#{node.role}{#{texify(node.text)}})
					end
				else
					texify(node.text)
				end
			end
		end

		private

		def texify str
			str = str
				.gsub(/&#([0-9]+);/){ $1.to_i.chr(Encoding::UTF_8) }
				.rstrip
		end

		def get_root_document node
			while (node = node.document).nested?
				node = node.parent_document
			end
			node
		end
	end

end # AsciidoctorLaTexCore

=begin
Copyright René Ferdinand Rivera Morell
Distributed under the Boost Software License, Version 1.0.
(See accompanying file LICENSE_1_0.txt or copy at
http://www.boost.org/LICENSE_1_0.txt)
=end
