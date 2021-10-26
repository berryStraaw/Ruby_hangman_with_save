require 'json'
fname="the_odin_project/Ruby_hangman_with_save/5desk.txt"

def wordPick(fname)
    file=File.open(fname,"r"){|file| file.read}
    string=file.split()
    string.select!{|word| word.length>=5 && word.length<=12}
    return string.sample
end

def askLoad()
    puts "would you like to load in previous game? yes(1) or no(2)"
    if gets.chomp=="1"
        return true
    else
        return false
    end
end

class Game
    attr_accessor :word
    attr_reader :tries
    attr_accessor :user_display
    attr_reader :win

    def initialize(word="WorDd", tries=6,user_display="")
        @win=false
        @tries=tries
        @word=word                       
        @split_word=@word.split("")
        @user_display=user_display
        p @word                                  # debug
        if @user_display==""
            @word.each_char{|i| @user_display<<"_ "}
        end
        p @user_display                                 #debug
        @split_display=@user_display.split(" ")
    end

    def ask_input()
        check=false
        while !check
            puts "please enter a letter:"
            letter=gets.chomp
            check=inputIsValid?(letter)
        end
        letter=letter.downcase
        return letter
    end
    
    def inputIsValid?(inp)
        inp=inp.downcase
        if inp.length>1 || inp.length<1
            puts "invalid input"
            false
        elsif !inp.match(/[a-z]/)
            puts "invalid input"
            return false
        elsif @split_display.any?{|letter| letter.downcase==inp}
            puts "already tried this letter"
            return false
        else
            true
        end
    end

    def feedback(inp)
        checkword=@word.downcase.split("")
        correct_pos=[]
        checkword.each_with_index do |letter,i|
            if letter==inp
                correct_pos.push(i)
            end
        end
        if correct_pos.empty?
            puts "Letter not in the word"
            @tries-=1
        else 
            puts "Correct!"
        end

        @split_display=@user_display.split(" ")
        @split_word=@word.split("")
        correct_pos.each do |i|
            @split_display[i]=@split_word[i]
            @user_display=@split_display.join(" ")
            if @split_display.join("")==@word
                @win=true
                return hasWon()
            end
        end
        return display()
    end

    def display()
        puts "#{@tries} tries left"
        return @user_display
    end
    def hasWon()
        p @user_display
        p word
        return "You win with #{@tries} tries left"
    end

    def askSave()
        puts "would you like to save? yes(1) or no(2)"
        if gets.chomp=="1"
            string=JSON.dump({
                :word => @word,
                :tries=> @tries,
                :user_display => @user_display
            })
            File.open("the_odin_project/Ruby_hangman_with_save/save.json", "w") do |game_file|
                game_file.write(string)
                end
            puts "progress has been saved"
        end
    end

    def self.load(string)
        data = JSON.load string
        self.new(data['word'], data['tries'], data['user_display'])
    end
end

if askLoad()
    save_file=File.read("the_odin_project/Ruby_hangman_with_save/save.json")
    game=Game.load(save_file)
    puts "progress has been loaded"
else
    game=Game.new(word=wordPick(fname))
end

#game=Game.new(word=wordPick(fname))
while game.tries()>0 && game.win()!=true
    game.askSave()
    choice=game.ask_input()
    p game.feedback(choice)
end

