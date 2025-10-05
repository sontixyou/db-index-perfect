namespace :searchkick do
  desc "Reindex all searchkick models"
  task reindex_all: :environment do
    puts "Reindexing User model..."
    User.reindex
    puts "User reindex complete!"

    puts "Reindexing UserProfile model..."
    UserProfile.reindex
    puts "UserProfile reindex complete!"

    puts "All models reindexed successfully!"
  end

  desc "Reindex limited number of records for testing"
  task reindex_sample: :environment do
    limit = ENV.fetch("LIMIT", 1000).to_i

    puts "Reindexing #{limit} User records..."
    User.limit(limit).find_in_batches(batch_size: 100) do |batch|
      User.search_index.import(batch)
      print "."
    end
    puts "\nUser sample reindex complete!"

    puts "Reindexing #{limit} UserProfile records..."
    UserProfile.limit(limit).find_in_batches(batch_size: 100) do |batch|
      UserProfile.search_index.import(batch)
      print "."
    end
    puts "\nUserProfile sample reindex complete!"

    puts "Sample reindex complete!"
  end
end
