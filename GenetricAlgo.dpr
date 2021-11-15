program GenetricAlgo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, System.Classes;

const
  _randomChars: string =
    ('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~ ');

type
  Tmylist = class(TList)

  public
    procedure Clear; override;
  end;

  TGen = class
  private
    fgen_code: string;
    ffitness: real;
  public
    constructor create(const agen_code: string);
    function get_fitness(const target: string): real;
    function mutate(const mutationRate: real): real;
    function crosover(mate: TGen): TGen;
    function get_string(): string;
  end;

  TGeneticAlgo = class
  private
    ftarget_genCode: string;
    fpopulation: Tmylist;
    fhighest_fitness: real;
    ffitest_gen: TGen;
    fnum_generations: integer;

    fgenreation_size: integer;
  public
    constructor create(const ATarget_Gen: string;
      genreation_size: integer = 1000);
    procedure init_populations();
    procedure popluation_fitness();
    procedure next_generation();
    function is_fittest_found(): boolean;
    function get_fittest_geneStr(): string;
    function get_totalGenCreated(): integer;
    destructor Destroy; override;
  end;

  { TGen }

constructor TGen.create(const agen_code: string);
begin
  fgen_code := agen_code;
  ffitness := 0;
end;

function TGen.crosover(mate: TGen): TGen;
var
  mid_point: integer;
  i: integer;
  r_index: integer;
begin
  result := TGen.create('');
  mid_point := random(length(fgen_code)) + 1;
  for i := 1 to length(fgen_code) do
  begin
    if (i < mid_point) then
      result.fgen_code := result.fgen_code + fgen_code[i]
    else
      result.fgen_code := result.fgen_code + mate.fgen_code[i];
  end;
  r_index := random(length(fgen_code)) + 1;
  (* mid_point := random(r_index) + 1;
    for i := 1 to r_index - 1 do
    begin
    if (i > mid_point) then
    result.fgen_code[i] := mate.fgen_code[i];
    end;
  *)
  result.fgen_code[r_index] := mate.fgen_code[r_index];
  r_index := random(length(fgen_code)) + 1;
  result.fgen_code[r_index] := fgen_code[r_index];

end;

function TGen.get_fitness(const target: string): real;
var
  fitness_level: integer;
  i: integer;
begin

  fitness_level := 0;
  for i := 1 to length(target) do
    if (target[i] = fgen_code[i]) then
      fitness_level := fitness_level + 1;
  ffitness := (fitness_level / length(target));
  result := ffitness;
end;

function TGen.get_string: string;
begin
  result := fgen_code;
end;

function TGen.mutate(const mutationRate: real): real;
var
  i: integer;
  r_index: integer;
  temp: char;
begin
  for i := 1 to length(fgen_code) do
    if ((random(10000)) < 10) then
    begin
      r_index := random(length(fgen_code)) + 1;
      fgen_code[r_index] := _randomChars[random(length(_randomChars)) + 1];
    end;

end;

{ TGeneticAlgo }

constructor TGeneticAlgo.create(const ATarget_Gen: string;
  genreation_size: integer = 1000);
begin
  fpopulation := Tmylist.create;
  ftarget_genCode := ATarget_Gen;
  fgenreation_size := genreation_size;

  // init_populations();
end;

destructor TGeneticAlgo.Destroy;
begin
  fpopulation.Clear;
  inherited;
end;

function TGeneticAlgo.get_fittest_geneStr: string;
begin
  result := '';
  if assigned(ffitest_gen) then
    result := ffitest_gen.get_string();
end;

function TGeneticAlgo.get_totalGenCreated: integer;
begin
  result := fnum_generations * fgenreation_size;
end;

procedure TGeneticAlgo.init_populations;
var
  i: integer;
  j: integer;
  agen_code: string;
begin
  fpopulation.Clear;
  fhighest_fitness := 0;
  fnum_generations := 0;
  ffitest_gen := nil;
  for i := 1 to fgenreation_size do
  begin
    agen_code := '';
    for j := 1 to length(ftarget_genCode) do
      agen_code := agen_code + _randomChars[random(length(_randomChars)) + 1];
    fpopulation.Add(TGen.create(agen_code));
  end;
  fnum_generations := fnum_generations + 1;
end;

function TGeneticAlgo.is_fittest_found: boolean;
begin
  result := fhighest_fitness >= 1.0;
end;

procedure TGeneticAlgo.next_generation;
var
  matingPool: TList;
  i: integer;
  j: integer;
  gen, parentOne, parentTwo: TGen;
  mutateRate: real;
begin
  mutateRate := 0.01;
  matingPool := TList.create;
  try
    for i := 0 to fpopulation.Count - 1 do
      for j := 0 to trunc(TGen(fpopulation.items[i]).ffitness *
        (random(trunc(0.1 * fgenreation_size)) + fgenreation_size * 0.001)) do
        matingPool.Add(fpopulation.items[i]);

    for i := 0 to fpopulation.Count - 1 do

    begin
      parentOne := TGen(matingPool.items[random(matingPool.Count)]);
      parentTwo := TGen(matingPool.items[random(matingPool.Count)]);
      gen := parentOne.crosover(parentTwo);
      gen.mutate(mutateRate);
      TGen(fpopulation.items[random(fpopulation.Count)]).fgen_code :=
        (gen.fgen_code);
      gen.Free;

    end;
    fnum_generations := fnum_generations + 1;
  finally
    matingPool.Free;
  end;
end;

procedure TGeneticAlgo.popluation_fitness;
var
  i: integer;
begin

  for i := 0 to fpopulation.Count - 1 do
  begin
    // calculate fitness
    TGen(fpopulation.items[i]).get_fitness(ftarget_genCode);
    //
    if TGen(fpopulation.items[i]).ffitness > fhighest_fitness then
    begin
      fhighest_fitness := TGen(fpopulation.items[i]).ffitness;
      ffitest_gen := TGen(fpopulation.items[i]);
    end;
  end;

end;

{ Tmylist }

procedure Tmylist.Clear;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Tobject(Get(i)).Free;
  inherited;

end;

var
  simulation: TGeneticAlgo;
  target_gen: string;

begin
  randomize;

  simulation := TGeneticAlgo.create('');
  try

    repeat
      writeln('--------------------------------------------');
      write('target gen <or exit>:');
      readln(target_gen);
      simulation.ftarget_genCode := target_gen;
      simulation.init_populations();
      try
        while not simulation.is_fittest_found() do
        begin
          // get next generation
          simulation.next_generation();
          // calculate new popluation fitness
          simulation.popluation_fitness();
          writeln(simulation.get_fittest_geneStr());
          sleep(0);
        end;
        writeln('--------------------------------------------------');
        writeln('Goal:', simulation.ftarget_genCode);
        writeln('generation count:', simulation.fnum_generations);
        writeln('total gen created:', simulation.get_totalGenCreated());
      except
        on E: Exception do
          writeln(E.ClassName, ': ', E.Message);
      end;
    until target_gen = 'exit';
  finally
    simulation.Free;
  end;
  readln;

end.
