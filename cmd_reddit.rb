require 'net/http'
require 'json'

$PROMPT = ">>"
$DEFAULT_ADDRESS = 'http://www.reddit.com/.json'
$CMD_EXIT = "exit"
$CMD_GET_NEXT_PAGE = "next"
$CMD_OPEN = "open"
$CMD_INSPECT = "inspect"

$current_article_count = 0
$current_after_identifier = ""

def execute_command(input)
	if input == $CMD_EXIT
		puts "Goodbye!"
		exit(0)
	end
	
	if input == $CMD_GET_NEXT_PAGE
		puts "Getting the next page..."
		next_address = $current_article_count == 0 ? $DEFAULT_ADDRESS : $DEFAULT_ADDRESS + get_next_address()
		puts next_address
		puts $current_after_identifier
		puts "---------------"
		http_response = get_http_response(next_address)
		to_display = format_page_http_response(http_response)
		set_next_address(http_response)
		puts to_display
	end
	
	if input == $CMD_OPEN
		puts "The open command is coming soon"
	end
	
	if input == $CMD_INSPECT
		puts "The inspect command is coming soon"
	end
end

def set_next_address(http_response)
	parsed_json = JSON.parse(http_response.body)
	page_contents = parsed_json['data']
	
	set_after_identifier(page_contents['after'])
	$current_article_count = $current_article_count.to_i + 25
end

def get_http_response(address)
	url = URI.parse(address)
    req = Net::HTTP::Get.new(url.path + get_next_address())
    http_response = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
	return http_response
end

def format_post_count(post_count)
	return "[##{post_count}]"
end

def format_score(score)
	return "{#{score}} "
end

def format_subreddit_and_domain(sub, domain, is_self)
	return is_self ? " <#{sub} -- self>" : " <#{sub} -- #{domain}>"
end

def format_page_http_response(http_response)
	parsed_json = JSON.parse(http_response.body)
	page_contents = parsed_json['data']['children']
	post_count = 0
	formatted_string = ""
	
	page_contents.each do |reddit_post|
		reddit_post = reddit_post['data']
		score = reddit_post['score']
		subreddit = reddit_post['subreddit']
		domain = reddit_post['domain']
		is_self = reddit_post['selftext'] != ""
		
		formatted_string << format_post_count(post_count)
		formatted_string << format_score(score)
		formatted_string << reddit_post['title']
		formatted_string << format_subreddit_and_domain(subreddit, domain, is_self)
		formatted_string << "\n"
		post_count += 1
	end
	
	return formatted_string
end

def set_after_identifier(after)
	$current_after_identifier = after
end

def set_article_count(count)
	current_article_count = count
end

def get_next_address()
	return "?count=#{$current_article_count}&after=#{$current_after_identifier}"
end

def print_string(string)
	puts string
end

begin
	while 1
		print $PROMPT
		input = gets.chomp()
		execute_command(input)
	end
end