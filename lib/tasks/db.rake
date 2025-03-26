# frozen_string_literal: true

namespace :db do
  desc 'Count Database Records'
  task count: [:environment] do
    [Bookmark, SinaiToken, Search, User].each do |model|
      puts "#{model.name}: #{model.count}"
    end
  end

  task truncate: [:environment] do
    Bookmark.connection.truncate("bookmarks")
    SinaiToken.connection.truncate("sinai_tokens")
    Search.connection.truncate("searches")
    User.connection.truncate("users")
  end
end
