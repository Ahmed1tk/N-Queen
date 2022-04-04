# N-Queens-AI
N Queens problem solved in lua using AI strategies such as BFS, IDS, A*, Hill climbing and Genitc algorithm

**Functions:**
  **BFS, IDS, A:**
  is_Safe(column, row, board):
    check if a given queen can be attacked from any queen in a given board 
  Goal_test(node):
    Test if a given node is a goal state using the is_Safe function
  Create_board(Qs):
    creates and returns a board of a given list of queen coordinates 
  Expand(node) :
    Expands the given node and returns its successors. A queen can move diagonally or linearly. Every queen can move one tile only in this function. This function also checks if the parent of the node moved in the opposite direction, to avoid loops. 
  Safely_Expand(node):
    Expands the given node and returns its successors if any. Else it returns the Expand function. A queen will move to the safest tile in its own column. This function can only be used with the all in first row start. 
  BFS(N):
    Uses the BFS strategy for solving the N queens problem and returns solution cost , search cost, and max size of the fringe/
  IDS(N):
    Uses the IDS strategy for solving the N queens problem and returns solution cost , search cost
  A_star(N):
    Uses the A* strategy for solving the N queens problem and returns solution cost , search cost, and max size of the fringe
  GetCost(Qs):
    Returns the cost of a given node by calculating how many under attack queens. 
    print_board(Qs):
    Prints a given board used for visualization or end results (has a 0.06sec delay for good visuals )
    
  **Hill climbing, Genitc algorithm:**
  is_Safe(column, row, board):
    check if a given queen can be attacked from any queen in a given board 
  Goal_test(node):
    Test if a given node is a goal state using the is_Safe function
  Create_board(Qs):
    creates and returns a board of a given list of queen coordinates 
  Expand(node) :
    Expands the given node and returns its successors. A queen can move north or south only. Every queen can move one tile only in this function. This function also checks if the parent of the node moved in the opposite direction, to avoid loops. 
  Safely_Expand(node):
    Expands the given node and returns its successors if any. Else it returns the Expand function. A queen will move to the safest tile in its own column.

  HillClimbing(problem):
    Uses the Hill climbing local search algorithm to solve the n-queens problem.	

  GeneticAlgorithm(n):
    Uses the genetic algorithm to solve the n-queens problem.
  GetCost(Qs):
    Returns the cost of a given node by calculating conflicts between queens, 
  print_board(Qs):
    Prints a given board used for visualization or end results (has a 0.06sec delay for good visuals )
