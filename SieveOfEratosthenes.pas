//
// Copyright (c) Jasper Schellingerhout. All rights reserved.
// Licensed under the MIT License. See LICENSE file in the project root for full license information.
//
// I kindly request that you notify me if you use this in your software projects.
// Project located at: https://github.com/schellingerhout/sieve-of-eratosthenes-delphi/

unit SieveOfEratosthenes;

interface

uses
  system.classes, system.SysUtils, system.generics.collections;

const
  BlockSize = 64;

type
  ArrayOfUInt32 = array of uint32;

  TSieveOfEratosthenes = Class
  private
    FMaxValue: uint32;
    FMaxValueISqrt: uint32; // Trunc(Sqrt(MaxValue))
    FMaxBlockIndex: uint32; // floor(MaxValue/BlockSize)
    FValueBitField: Array of UInt64; { [0 .. MaxBlockIndex] }
    function NumberOfBitsSet: uint32;
    procedure SetMaxValue(const Value: uint32);
    function GetNextPrime(APreviousPrime: uint32): uint32;

    procedure GetPrimeMask;
  public
    constructor Create;
    class function GetPrimes(const AMaxValue: uint32): ArrayOfUInt32;
  End;

implementation

uses
  system.Math;

{ TSieveOfErastothenos }
// https://stackoverflow.com/questions/2709430/count-number-of-bits-in-a-64-bit-long-big-integer
function TSieveOfEratosthenes.NumberOfBitsSet: uint32;
var
  i: integer;
  LBitFieldCount: UInt64;
begin
  result := 0;
  for i := 0 to FMaxBlockIndex do
  begin
    LBitFieldCount := FValueBitField[i] - ((FValueBitField[i] shr 1) and UInt64($5555555555555555));

    LBitFieldCount := (LBitFieldCount and UInt64($3333333333333333)) +
      ((LBitFieldCount shr 2) and UInt64($3333333333333333));

    // This will overflow by design
{$OVERFLOWCHECKS OFF}
    LBitFieldCount := byte((((LBitFieldCount + (LBitFieldCount shr 4)) and UInt64($F0F0F0F0F0F0F0F)) *
      UInt64($101010101010101)) shr 56);
{$OVERFLOWCHECKS ON}
    result := result + LBitFieldCount;
  end;
end;

procedure TSieveOfEratosthenes.SetMaxValue(const Value: uint32);
begin
  FMaxValue := Value;
  FMaxValueISqrt := Trunc(Sqrt(FMaxValue));
  FMaxBlockIndex := floor(FMaxValue / BlockSize);
  FValueBitField := nil; // will make ensure zeros when we call setlength below
  SetLength(FValueBitField, FMaxBlockIndex + 1);
end;

constructor TSieveOfEratosthenes.Create;
begin
  SetMaxValue(1000000);
end;

// PRE: APreviousPrime is prime and > 2
// POST: return value is the successor prime of the input
function TSieveOfEratosthenes.GetNextPrime(APreviousPrime: uint32): uint32;
var
  LBlock: UInt64;
  LBlockIndex: UInt64;
  LBlockBitIndex: UInt64;
begin
  DivMod(APreviousPrime + 2, BlockSize, LBlockIndex, LBlockBitIndex);
  repeat
    LBlock := FValueBitField[LBlockIndex] shr LBlockBitIndex;
    if LBlockBitIndex >= BlockSize then
    begin
      LBlockBitIndex := 0;
      inc(LBlockIndex);
    end
    else
      inc(LBlockBitIndex);
  until (LBlock and 1 = 0);
  result := LBlockIndex * BlockSize + LBlockBitIndex - 1;
end;

// class procedure TSieveOfEratosthenes.GetPrimeMask;
// PRE:  SetMaxValue has been called therefore FValueBitField is zeroed out
// POST: FValueBitField has bits set for non-prime values corresponding
// to index. Zero based index directly correlates to values
procedure TSieveOfEratosthenes.GetPrimeMask;
var
  i: uint32;
  LPrime: uint32;
  LMultiple: uint32;
  LNonPrime: UInt64;
  LBlockIndex: UInt64;
  LBlockBitIndex: UInt64;
begin
  // we could set the initial state of the blocks. since
  // multiples of 2 are really trivial bit patterns

  // first block has   repeat(0101) 0011
  FValueBitField[0] := UInt64($5555555555555553);
  for i := 1 to FMaxBlockIndex do
  begin
    // other blocks have repeat(0101)
    FValueBitField[i] := UInt64($5555555555555555);
  end;

  LPrime := 3;
  repeat
    LMultiple := LPrime;
    LNonPrime := LPrime * LMultiple;
    while LNonPrime <= FMaxValue do
    begin
      DivMod(LNonPrime, BlockSize, LBlockIndex, LBlockBitIndex);

      FValueBitField[LBlockIndex] := FValueBitField[LBlockIndex] or (UInt64(1) shl LBlockBitIndex);

      inc(LMultiple);

      LNonPrime := LPrime * LMultiple;
    end;
    LPrime := GetNextPrime(LPrime);
  until (LPrime >= FMaxValueISqrt);
end;

class function TSieveOfEratosthenes.GetPrimes(const AMaxValue: uint32): ArrayOfUInt32;
var
  LPrime: uint32;
  i: integer;
  j: uint32;
  LSieve: TSieveOfEratosthenes;
begin
  LSieve := TSieveOfEratosthenes.Create;
  try
    with LSieve do
    begin
      SetMaxValue(AMaxValue);
      GetPrimeMask;
      SetLength(result, NumberOfBitsSet - 1);
      result[0] := 2;
      result[1] := 3;
      LPrime := 3;

      i := 2;
      while (LPrime <= FMaxValue) and (LPrime > 0) do
      begin
        LPrime := GetNextPrime(LPrime);
        result[i] := LPrime;
        inc(i);
      end;
      SetLength(result, i - 1);
    end;
  finally
    FreeAndNil(LSieve);
  end;
end;

end.
