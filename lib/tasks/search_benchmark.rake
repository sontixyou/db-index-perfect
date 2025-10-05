namespace :search do
  desc "Benchmark Elasticsearch vs MySQL FULLTEXT vs LIKE search"
  task benchmark: :environment do
    query = ENV.fetch("QUERY", "Ruby")
    iterations = ENV.fetch("ITERATIONS", "10").to_i
    per_page = ENV.fetch("PER_PAGE", "20").to_i

    puts "=" * 80
    puts "Search Performance Benchmark"
    puts "=" * 80
    puts "Query: #{query}"
    puts "Iterations: #{iterations}"
    puts "Per page: #{per_page}"
    puts "Total UserProfiles: #{UserProfile.count}"
    puts "=" * 80
    puts ""

    results = {}

    # Elasticsearch benchmark
    print "Running Elasticsearch benchmark..."
    es_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search(query, fields: [:career], match: :word_start, per_page: per_page).to_a
      es_times << (Time.current - start_time) * 1000
      print "."
    end
    puts " Done!"
    results[:elasticsearch] = {
      avg: es_times.sum / es_times.size,
      min: es_times.min,
      max: es_times.max,
      all: es_times
    }

    # MySQL FULLTEXT benchmark
    print "Running MySQL FULLTEXT benchmark..."
    fulltext_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search_by_fulltext(query, per_page: per_page).to_a
      fulltext_times << (Time.current - start_time) * 1000
      print "."
    end
    puts " Done!"
    results[:mysql_fulltext] = {
      avg: fulltext_times.sum / fulltext_times.size,
      min: fulltext_times.min,
      max: fulltext_times.max,
      all: fulltext_times
    }

    # MySQL LIKE benchmark
    print "Running MySQL LIKE benchmark..."
    like_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search_by_like(query, per_page: per_page).to_a
      like_times << (Time.current - start_time) * 1000
      print "."
    end
    puts " Done!"
    results[:mysql_like] = {
      avg: like_times.sum / like_times.size,
      min: like_times.min,
      max: like_times.max,
      all: like_times
    }

    puts ""
    puts "=" * 80
    puts "RESULTS"
    puts "=" * 80
    puts ""

    puts "Elasticsearch:"
    puts "  Average: #{results[:elasticsearch][:avg].round(2)} ms"
    puts "  Min:     #{results[:elasticsearch][:min].round(2)} ms"
    puts "  Max:     #{results[:elasticsearch][:max].round(2)} ms"
    puts ""

    puts "MySQL FULLTEXT:"
    puts "  Average: #{results[:mysql_fulltext][:avg].round(2)} ms"
    puts "  Min:     #{results[:mysql_fulltext][:min].round(2)} ms"
    puts "  Max:     #{results[:mysql_fulltext][:max].round(2)} ms"
    puts ""

    puts "MySQL LIKE:"
    puts "  Average: #{results[:mysql_like][:avg].round(2)} ms"
    puts "  Min:     #{results[:mysql_like][:min].round(2)} ms"
    puts "  Max:     #{results[:mysql_like][:max].round(2)} ms"
    puts ""

    puts "=" * 80
    puts "COMPARISON"
    puts "=" * 80
    puts ""

    es_avg = results[:elasticsearch][:avg]
    fulltext_avg = results[:mysql_fulltext][:avg]
    like_avg = results[:mysql_like][:avg]

    puts "MySQL FULLTEXT is #{(fulltext_avg / es_avg).round(2)}x #{fulltext_avg > es_avg ? 'slower' : 'faster'} than Elasticsearch"
    puts "MySQL LIKE is #{(like_avg / es_avg).round(2)}x #{like_avg > es_avg ? 'slower' : 'faster'} than Elasticsearch"
    puts "MySQL LIKE is #{(like_avg / fulltext_avg).round(2)}x #{like_avg > fulltext_avg ? 'slower' : 'faster'} than FULLTEXT"
    puts ""

    # Winner
    winner = results.min_by { |k, v| v[:avg] }
    puts "🏆 Winner: #{winner[0].to_s.upcase} (#{winner[1][:avg].round(2)} ms average)"
    puts ""
    puts "=" * 80
  end

  desc "Test search results consistency across methods"
  task test_consistency: :environment do
    query = ENV.fetch("QUERY", "Ruby")
    per_page = ENV.fetch("PER_PAGE", "20").to_i

    puts "Testing search consistency for query: '#{query}'"
    puts ""

    # Elasticsearch results
    es_results = UserProfile.search(query, fields: [:career], match: :word_start, per_page: per_page).to_a
    puts "Elasticsearch: #{es_results.size} results"

    # MySQL FULLTEXT results
    fulltext_results = UserProfile.search_by_fulltext(query, per_page: per_page).to_a
    puts "MySQL FULLTEXT: #{fulltext_results.size} results"

    # MySQL LIKE results
    like_results = UserProfile.search_by_like(query, per_page: per_page).to_a
    puts "MySQL LIKE: #{like_results.size} results"

    puts ""
    puts "Note: Result counts may differ due to different search algorithms"
    puts "- Elasticsearch uses word_start matching"
    puts "- MySQL FULLTEXT uses natural language mode"
    puts "- MySQL LIKE uses simple pattern matching"
  end
end
