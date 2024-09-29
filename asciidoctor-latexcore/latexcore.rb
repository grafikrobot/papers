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
			result << gen_section_title(node)

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
			result << gen_section_title(node)
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
			result << %(
\\begin{outputblock}
#{texify(node.content)}
\\end{outputblock})
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
			if role?(node, 'itemdescr')
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
			case node.type
			when :xref
				node_refid = node.attributes['refid']
				root_doc = get_root_document node
				ref = root_doc.resolve_id(node_refid)
				iref = ref ? ref.xreftext : node.text
				%(\\iref{#{iref}})
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
				if IGNORED_SCOPES.include?(role?(node))
					nil
				elsif role?(node, 'iref')
					%(\\iref{#{texify(node.text)
						.sub(/^\(\[/,'').sub(/\]\)$/,'')}})
				elsif role?(node, 'fldname')
					%(\\pnum \\fldname)
				elsif role?(node, 'fldtype')
					%(\\pnum \\fldtype)
				elsif role?(node, 'fldval')
					%(\\pnum \\fldval)
				elsif role?(node, 'flddesc')
					%(\\pnum \\flddesc)
				elsif role? node
					%(\\#{role? node}{#{texify(node.text)}})
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

		def role? node, role_name = nil
			if role_name
				(node.has_role? role_name) ? role_name : nil
			elsif node.role
				node.roles[0]
			else
				nil
			end
		end

		def gen_section_title node
			result = []
			node_level = node.level - (node.document.attributes['leveldedent'] || '0').to_i
			if role?(node, 'ignore')
				nil
			elsif role?(node, 'infannex')
				result << %(\
\% #{node.title.strip}
\\infannex[#{node.reftext}]{#{node.title.strip}}
)
			else
				result << %(\
\% #{node.title.strip}
\\rSec#{node_level}[#{node.reftext}]{#{node.title.strip}}
)
			end
			return result
		end
	end

end # AsciidoctorLaTexCore

=begin
Copyright René Ferdinand Rivera Morell
Distributed under the Boost Software License, Version 1.0.
(See accompanying file LICENSE_1_0.txt or copy at
http://www.boost.org/LICENSE_1_0.txt)
=end
