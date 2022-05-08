package common_globals is
  type globals_t is protected 
  -- fuckery, so I can abstract away the std_logic random generator
    impure function seed1_get return integer;
    procedure seed1_set(x : integer);
    impure function seed2_get return integer;
    procedure seed2_set(x : integer);
  end protected;
end package;

package body common_globals is
  type globals_t is protected body

    variable seed1 : integer := 21;
    impure function seed1_get return integer is
    begin
      return seed1;
    end function;
    procedure seed1_set(x : integer) is
    begin
      seed1 := x;
    end procedure;

    variable seed2 : integer := 32432;
    impure function seed2_get return integer is
    begin
      return seed2;
    end function;
    procedure seed2_set(x : integer) is
    begin
      seed2 := x;
    end procedure;

  end protected body;
end package body;
