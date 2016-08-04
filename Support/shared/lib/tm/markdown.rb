module TextMate
	module Markdown
		module_function
		def to_html(str, options = { })
			filters = [ ]
			if ENV.has_key?('TM_MARKDOWN_PRE_FILTER')
				filters += ENV['TM_MARKDOWN_PRE_FILTER'].split(':').reject{ |s| s == '' }
			end
			filters << (ENV.has_key?('TM_MARKDOWN')    ? '$TM_MARKDOWN'    : '"$TM_SUPPORT_PATH/bin/Markdown.pl"')    unless options[:no_markdown]
			filters << (ENV.has_key?('TM_SMARTYPANTS') ? '$TM_SMARTYPANTS' : '"$TM_SUPPORT_PATH/bin/SmartyPants.pl"') unless options[:no_smartypants]
			if ENV.has_key?('TM_MARKDOWN_POST_FILTER')
				filters += ENV['TM_MARKDOWN_POST_FILTER'].split(':').reject{ |s| s == '' }
			end

			return str if filters.empty?

			IO.popen(filters.join('|'), 'r+') do |io|
				Thread.new { io << str; io.close_write }
				io.read
			end
		end
	end
end

if $0 == __FILE__
	include TextMate
	puts Markdown.to_html("who's there?")
	puts Markdown.to_html("who's there?", :no_markdown => true)
	puts Markdown.to_html("who's there?", :no_smartypants => true)
	puts Markdown.to_html("who's there?", :no_markdown => true, :no_smartypants => true)
end
