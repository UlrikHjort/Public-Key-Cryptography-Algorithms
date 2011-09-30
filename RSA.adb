-------------------------------------------------------------------------------
--                                                                           --
--                                   RSA                                     --
--                                                                           --
--                                 RSA.adb                                   --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 1997 Ulrik Hørlyk Hjort                   --
--                                                                           --
--  RSA is free software;  you can  redistribute it                          --
--  and/or modify it under terms of the  GNU General Public License          --
--  as published  by the Free Software  Foundation;  either version 2,       --
--  or (at your option) any later version.                                   --
--  RSA is distributed in the hope that it will be                           --
--  useful, but WITHOUT ANY WARRANTY;  without even the  implied warranty    --
--  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  --
--  See the GNU General Public License for  more details.                    --
--  You should have  received  a copy of the GNU General                     --
--  Public License  distributed with Yolk.  If not, write  to  the  Free     --
--  Software Foundation,  51  Franklin  Street,  Fifth  Floor, Boston,       --
--  MA 02110 - 1301, USA.                                                    --
--                                                                           --
-------------------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces; use Interfaces;

package body RSA is

   ---------------------------------------------------------------------------
   --
   -- Converting a message block to a human readable string
   --
   ---------------------------------------------------------------------------
   procedure Blocks_To_Message(Blocks : in Large_Positive_Array_T; Message : out String) is
      Block_Index : Large_Positive := 1;
      Block       : Large_Positive := 0;

   begin
      for Index in Message'First .. Message'Last-1 loop
         if Index mod 2 = 1 then
            Block := Blocks(Block_Index);
            Message(Index) := Alphabet((Block/100)-1);
            Message(Index+1) := Alphabet(Block - ((Block/100) *100)-1);
            Block_Index := Block_Index + 1;
         end if;
      end loop;
   end Blocks_To_Message;


   ---------------------------------------------------------------------------
   --
   -- Converting a text string into a cipher block
   --
   ---------------------------------------------------------------------------
   procedure Message_To_Blocks(Message : String; Blocks : out Large_Positive_Array_T) is
      Block_Index : Large_Positive := 1;

   begin
      for Index in Message'First .. Message'Last-1 loop
         if Index mod 2 = 1 then
            Blocks(Block_Index) := (Char_Index(Char_Range(Message(Index))) * 100) +
              (Char_Index(Char_Range(Message(Index+1))));
            Block_Index := Block_Index +1;
         end if;
      end loop;

      if Message'Length mod 2 = 1 then
            Blocks(Blocks'last) := (Char_Index(Char_Range(Message(Message'Last-1))) * 100) +
              (Char_Index(Char_Range(Message(Message'last))));
         end if;
   end Message_To_Blocks;


   ---------------------------------------------------------------------------
   --
   -- Print the elements in the cipher block.
   --
   ---------------------------------------------------------------------------
   procedure Print_Cipher_Block(BC : Large_Positive_Array_T) is

   begin
      for I in BC'First .. BC'Last loop
         Put(Unsigned_32'Image(Unsigned_32(BC(I))) & " ");
      end loop;
         New_Line;
   end Print_Cipher_Block;


   -----------------------------------------------------------------------------
   -- Demonstration of a iterative attack on a cipher with the public known keys
   -- N,E after the following algorithm:
   --
   --  (Initial_Element ** 2)   mod N = I1
   --               (I1 ** 2)   mod N = I2
   --                                  .
   --                                  .
   --                                  .
   --               (In-1 ** 2) mod N = In
   --                 (In ** 2) mod N = Initial_Element
   --
   -- Where (In-1) is the clear text value;
   ---------------------------------------------------------------------------
   procedure Iterative_Attack(Cipher_Block : in out Large_Positive_Array_T;
                              N : Large_Positive;
                              E : Large_Positive) is

      Initial_Element    : constant Large_Positive := Cipher_Block(Cipher_Block'First);
      Result             : Large_Positive          := Initial_Element;
      Iterations         : Positive                := 1;

      Decrypted_Text : String(1..Cipher_Block'Length * 2);

   begin
      New_Line;
      Put_Line("Iterative attack stated");

      Infinite_Loop:
      loop
         Result := Slow_Reduce_Large_Exponent_Modulus(Result,Natural(E),N);
         exit Infinite_Loop When Result = Initial_Element;
         for Index in Cipher_Block'First .. Cipher_Block'Last loop
            Cipher_Block(Index) := Slow_Reduce_Large_Exponent_Modulus(Cipher_Block(Index),Natural(E),N);
            end loop;
         Iterations := Iterations + 1;
      end loop Infinite_Loop;
      Put_Line("Iterative attack stopped with succes");
      Blocks_To_Message(Cipher_Block, Decrypted_Text);
      New_Line;
      Put_Line("Cipher decrypted after# " & Integer'Image(Iterations) & " iterations");
      Put_Line("Decrypted text: " & Decrypted_Text);

   end Iterative_Attack;


   ---------------------------------------------------------------------------
   --
   -- Example of RSA crypt, decrypt and a iterative attack on a cipher text
   --
   ---------------------------------------------------------------------------
   procedure RSA_Example is
      P : constant Large_Positive := Get_Prime(100);
      Q : constant Large_Positive := Get_Prime(P*3);
      N   : constant Large_Positive := P*Q;
      Phi : constant Large_Positive := (P-1)*(Q-1);
      E   : constant Large_Positive := Get_CoPrime(Phi);
      D   : constant Large_Positive := Get_Inverse(E,Phi);

      Plain_Text : constant String := "THECLEARTEXTTOBECRYPTED";
      Decrypted_Text : String(1..Plain_Text'Length);
      Cipher_Block : Large_Positive_Array_T (1 .. Plain_Text'Length/2);

   begin
      Put_Line("L " & Integer'Image(Plain_Text'Length));
      Put_Line("P = " & Integer'Image(Integer(P)));
      Put_Line("Q = " & Integer'Image(Integer(Q)));
      Put_Line("N = " & Integer'Image(Integer(N)));
      Put_Line("Phi = " & Integer'Image(Integer(Phi)));
      Put_Line("E = " & Integer'Image(Integer(E)));
      Put_Line("D = " & Integer'Image(Integer(D)));

      Message_To_Blocks(Plain_Text,Cipher_Block);

      Print_Cipher_Block(Cipher_Block);
      -- Crypt:
      for I in Cipher_Block'First .. Cipher_Block'Last loop
        Cipher_Block(I) := Slow_Reduce_Large_Exponent_Modulus(Cipher_Block(I),Natural(E),N);
      end loop;

      Print_Cipher_Block(Cipher_Block);
      -- Decrypt:
      for I in Cipher_Block'First .. Cipher_Block'Last loop
        Cipher_Block(I) := Slow_Reduce_Large_Exponent_Modulus(Cipher_Block(I),Natural(D),N);
      end loop;

      Print_Cipher_Block(Cipher_Block);

      Blocks_To_Message(Cipher_Block, Decrypted_Text);
      Put_Line("Decrypted: " & Decrypted_Text);

      -- Crypt:
      for I in Cipher_Block'First .. Cipher_Block'Last loop
        Cipher_Block(I) := Slow_Reduce_Large_Exponent_Modulus(Cipher_Block(I),Natural(E),N);
      end loop;
      Print_Cipher_Block(Cipher_Block);
      Iterative_Attack(Cipher_Block,N,E);
   end RSA_EXample;
end RSA;
