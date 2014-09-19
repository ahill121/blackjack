
#Blackjack


require "mysql2"


class Game 

	def initialize(deck,player_hand,dealer_hand)
    @player_won=nil
    @game_id=nil
    @mysql = Mysql2::Client.new(host: '127.0.0.1', username: 'root', database: 'blackjack')
		@deck = deck
  	@player_hand = player_hand
 		@dealer_hand =dealer_hand
  		puts "Your hand:" + identify_card(@player_hand[0]) + " and " + identify_card(@player_hand[1]) + " for a score of " + score_hand(@player_hand).to_s
  		puts "Dealer's hand: #{identify_card(@dealer_hand[0])}"  
  		game_loop
	end


  def save_game(name)
    m=@money
    @mysql.query "INSERT INTO games (name) VALUES ('#{name}')"
    result = @mysql.query "SELECT LAST_INSERT_ID() as id"
    @game_id=result.first["id"]
    save_card_loop
    
  end

  def save_deck_cards(id_number, value)

    @mysql.query "INSERT INTO game_cards (game_id, card_value, pile) VALUES (#{id_number}, #{value}, 'deck')"
  
  end

  def save_dealer_cards(id_number, value)

    @mysql.query "INSERT INTO game_cards (game_id, card_value, pile) VALUES (#{id_number}, #{value}, 'dealer')"
  
  end

  def save_player_cards(id_number, value)

    @mysql.query "INSERT INTO game_cards (game_id, card_value, pile) VALUES (#{id_number}, #{value}, 'player')"
  
  end



def save_card_loop
    until @deck.empty? 
      save_deck_cards(@game_id, @deck.pop)
    end
    until @player_hand.empty?
       save_player_cards(@game_id, @player_hand.pop)
    end
    until @dealer_hand.empty?
       save_dealer_cards(@game_id, @dealer_hand.pop)
    end
  end


	def game_loop

		loop do
			puts "Would you like to (h)it, (s)tand, (q)uit, or (save)?"
    		answer = gets().downcase.strip
    		case 
           when answer == "save"
            puts "What would you like to name your game??"
            n=gets
            save_game(n)
            puts "Game Saved!!"
            abort

      			when answer == "q"
        	
      			when answer == "h"
        			player_hit
        			break if score_hand(@player_hand) > 21
     			when answer == "s"
       				player_stand
      
       	 end

    	end
      @player_won

  	end

    def player_won?
      @player_won
    end

  	
  	def get_value(card)
  		case card%13
    		when 0,11,12 then return 10
   			when 1 then return 11 
   			else return card%13
    	end
  	end

  	def identify_card(card) 
 		 suit = (case (card-1)/13
         		 when 0 then " of hearts"
         		 when 1 then " of clubs"
          		when 2 then " of diamonds"
          		when 3 then " of spades"
          		else raise StandardError
         		 end)  #end case
  		case card%13
   		 when 1 then return "Ace" + suit
   		 when 11 then return "Jack" + suit
    		when 12 then return "Queen" + suit
    		when 0 then return "King" + suit
   		 else return (card%13).to_s + suit
 		 end 
	end 


	def score_hand(hand) 
  	total=0
 		aces=0
  		hand.each  do |i|
    		aces+=1 if i%13==1
    		total+=get_value(i)
    		while total>21 do
     			if aces>0 then
       				total = total-10
      				 aces-=1
      			end #end if
     		 break if aces == 0
    		end #end while     
  		end #end do
 		total 
	end #end score_hand


	def player_hit
		@player_hand<<@deck.pop
		puts "You drew the " + identify_card(@player_hand[@player_hand.length-1])
		puts "Your score is now " + score_hand(@player_hand).to_s
    if score_hand(@player_hand) > 21 
      puts "You lose this round!!" 
      @player_won=false 
    end
	end

	def player_stand  
		puts "You stand with a score of " + score_hand(@player_hand).to_s
		"Dealer shows the " + identify_card(@dealer_hand[0]) + " and a " + identify_card(@dealer_hand[1]) + " for a score of " + score_hand(@dealer_hand).to_s
	 if score_hand(@dealer_hand)>16
      puts "Dealer stands" 
      if score_hand(@dealer_hand)>score_hand(@player_hand)
        @player_won=false
      end
      if score_hand(@dealer_hand)<score_hand(@player_hand)
        @player_won=true
      end
      else @player_won=nil
   end

		while score_hand(@dealer_hand)<17
			@dealer_hand<<@deck.pop
			puts "Dealer draws the #{identify_card(@dealer_hand[@dealer_hand.length-1])}" 
			puts "Dealer's score is now #{score_hand(@dealer_hand).to_s}"
      if score_hand(@dealer_hand)>21  
			 puts "Dealer busts.  You win this round!!" 
       @player_won=true
		  end
    end

		if score_hand(@dealer_hand)>score_hand(@player_hand) && score_hand(@dealer_hand)<22 then puts "You lose!!"
		elsif score_hand(@dealer_hand) < score_hand(@player_hand) || score_hand(@dealer_hand)>21 then puts "You win!!"
  		else puts "It's a draw!!"
  		end
  	end

end 

# Game.new

