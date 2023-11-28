#parameters for the variable
#limit indices
param I>=0; #home games;
param J>=0; #away games;
param L>=0; #weeks;
param S>=0; #num players in north
param d {i in 1..I, j in 1..J} >= 0; #distances
param Smin>=0; #start index for south
param Smax>=0;# end index for south



#variable declaration
var x {i in 1..I, j in 1..J, l in 1..L} binary; #games I hosts J in week L:

var y {i in 1..I, l in 1..8} binary; #back to back travel games


minimize TotalDistance:
     sum{i in 1..I, j in 1..J, l in 1..L}
        x[i, j, l] * d[i, j] +
        1000000 * (sum{i in 1..I, l in 1..8} y[i,l]);
        
	
#Play everyone once in your division and three teams in the other division selected “randomly” – 
	#total of eight games (will not play three opponents) - done.
#4 home, 4 away, 1 bye (either 2 or 3 home division games) - done.
#Teams should not have more than 1 back to back road trip. - done.
#Must not start or end the season with back-back road games - done.

#soft constraints 
#-	Make the schedule as balanced as possible so that no one gets a “great” schedule 
#   while some other team gets a “bad” schedule
#-	Make the “out of division” schedule as travel “friendly” as possible

#hard constraints     

#each north plays north once;
subject to NorthNorth1X {i in 1..S-1, j in i+1..S}: 
	sum{l in 1..L} (x[i,j,l]+x[j,i,l]) = 1;

#each south plays south once;
subject to SouthSouth1X {i in Smin..Smax-1, j in i+1..Smax}: 
     sum{l in 1..L} (x[i,j,l]+x[j,i,l]) = 1;
     
#Every north team plays a different south team three times
subject to NorthSouth3x {i in 1..S}:
	 sum{l in 1..L, j in Smin..Smax} (x[i,j,l]+x[j,i,l]) = 3;
	 
#Play at a max each opponent once
subject to DifferentGames{i in 1..J, j in 1..J: i<>j}:
	sum{l in 1..L} (x[i,j,l] + x[j,i,l]) <= 1;
	
# team 1 per week max 1 match
subject to Team1Matched1PerWeek { l in 1..L}:
	sum{j in 1..J} (x[1,j,l] + x[j,1,l] ) <= 1;

# team 2 - 11 per week max 1 match
subject to Team2to11Match1PerWeek {i in 2..I-1, l in 1..L}: 
	sum{j in i+1..J} (x[i,j,l]+x[j,i,l])+
	sum{j in 1..i-1} (x[j,i,l]+x[i,j,l]) <= 1;

# team 12 max 1 match/week
subject to Team12max1matchweek { l in 1..L }: 
	sum{i in 1..I-1} (x[i,12,l]+x[12,i,l]) <= 1;
	
#Total of 8 games per team over the 9 weeks
subject to TotalGamesPerTeam {i in 1..I}:
    sum {j in 1..I, l in 1..L: i<>j} (x[i,j,l]+x[j,i,l]) = 8;
    
#4 home games per team (either 2 or 3 home division games): sub constraints below
subject to HomeGamesPerTeam4x {i in 1..I}:
    sum {j in 1..J, l in 1..L} x[i, j, l] = 4;
    
     #2 <= North home division games <=3
subject to NorthGamesPerTeamInDiv3x {i in 1..S}:
   2 <= sum {j in 1..S, l in 1..L} x[i, j, l] <= 3;

     #2 <= #South home division games <=3
subject to SouthGamesPerTeamInDiv3x {i in Smin..Smax}:
    2 <= sum {j in Smin..Smax, l in 1..L} x[i, j, l] <= 3;
     
#4 away games
subject to Away{j in 1..J}:
	sum{i in 1..I,l in 1..L} x[i,j,l] = 4;   


subject to YDEFINE {i in 1..I, l in 1..L-1}:
	sum{j in 1..J} (x[i,j,l] + x[i,j,l+1]) + y[i,l] >= 1;

subject to NoMoreThan1Back2BackAway {i in 1..I}:
	sum{l in 1..L-1} y[i,l] <= 1;

#No back to back away games first 2 weeks
subject to NoAwayF2{i in 1..I}:
	sum{l in 1..3, j in 1..12} (x[i,j,l]) >= 1;

#No back to back away games last 2 weeks
subject to NoAwayL2{i in 1..I}:
	sum{l in 8..9, j in 1..12} (x[i,j,l]) >= 1;

#no byes first 2 weeks
subject to noByeFirst2{l in 1..2}:
	sum{i in 1..I,j in 1..J} x[i,j,l]=6;

#no byes last 2 weeks
subject to noByeLast2{l in 8..9}:
	sum{i in 1..I,j in 1..J} x[i,j,l]=6;
	
#No team may play itself across all weeks
subject to NoPlayUrself{l in 1..L}:
	sum{i in 1..I} x[i,i,l] = 0;
	
#No More than 4 byes per week
subject to NoMore2ByesPerWeek {l in 1..L}:
	sum{i in 1..I, j in 1..J} x[i,j,l] >= 4;

#-	The biggest TV games are Tahiti-Fiji, Sweden-Denmark, Chile-Argentina, and Antarctica-Australia. 
#In order to maximize TV revenue for the conference, they’d like it if all these games were in different weeks.
subject to MaxTvRev{l in 1..L-1}: 
	x[11,12,l] + x[12,11,l] + x[11,12,l+1] + x[12,11,l+1] + #Tahiti/Fiji
	x[3,5,l] + x[5,3,l] + x[3,5,l+1] + x[5,3,l+1] +#Sweden/Denamrk
	x[9,10,l] + x[10,9,l] + x[9,10,l+1] + x[10,9,l+1]+ #Chile/Argentina
	x[7,8,l] + x[8,7,l] + x[7,8,l+1] + x[8,7,l+1] <= 1; #Australia/Antarctica


