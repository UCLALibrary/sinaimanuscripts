class AddIndexToSinaiTokens < ActiveRecord::Migration[5.2]
  def change
    add_index :sinai_tokens, :sinai_token
  end
end
