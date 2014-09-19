
#Here I want to put the whole game together with a loop that will call "gameclass" to play each round. 


require "mysql2"

require_relative 'gameclassARH'


class BlackJack

	def initialize
		@playing=true
		@mysql = Mysql2::Client.new(host: '127.0.0.1', username: 'root', database: 'blackjack')
		puts "Welcome to BlackJack!!"
		puts "To start a new game, enter 1.  To load a game, enter 2."

		c=gets.to_i


		if c==2
			
			puts 'Listing all games, most recent first'
			games = @mysql.query "SELECT * FROM games ORDER BY id DESC"

			games.each do |game|
				 puts "#{game['id']}:  #{game['name']}"
			end

			puts "Please enter the id"

			id=gets.to_i

			cards = @mysql.query "SELECT * FROM game_cards where game_id=#{id}"

			if cards.count>0 
				deck, player_hand, dealer_hand = [],[],[]
				cards.each do |card|
					if card['pile']=='deck'
						deck<<card['card_value']
					end

					if card['pile']=='dealer_hand'
						dealer_hand<<card['card_value']
					end

					if card['pile']=='player_hand'
						player_hand<<card['card_value']
					end

				end

				game_loop(deck,player_hand,dealer_hand)


			else
				abort
			end



		elsif c==1 
			deck = (1..52).to_a.shuffle  
  			player_hand = [deck.pop,deck.pop] 
 			dealer_hand = [deck.pop,deck.pop]  
			@money=100
			game_loop(deck,player_hand,dealer_hand)
		end

	end

	def game_loop(deck,player_hand,dealer_hand)

	
		while @playing==true 

			puts "Place your bet"
			bet=gets.to_i

			game=Game.new(deck,player_hand,dealer_hand)
			game_in_progress=true
			if game.player_won?
				@money+=bet
			else
				@money-=bet
			end

			puts "Your money: #{@money}" 

			if @money>1000
				@playing = false
				puts "You win!!!!!!"
			end

			if @money<0
				@playing=false
				puts "You lost."
			end


		end

	end

end





BlackJack.new



