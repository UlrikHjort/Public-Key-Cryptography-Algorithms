-------------------------------------------------------------------------------
--                                                                           --
--                             Merkle Hellman                                --
--                                                                           --
--                           Merkle_Hellman.adb                              --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 1997 Ulrik Hørlyk Hjort                   --
--                                                                           --
--  Merkle Hellman is free software;  you can  redistribute it               --
--  and/or modify it under terms of the  GNU General Public License          --
--  as published  by the Free Software  Foundation;  either version 2,       --
--  or (at your option) any later version.                                   --
--  Merkle Hellman is distributed in the hope that it will be                --
--  useful, but WITHOUT ANY WARRANTY;  without even the  implied warranty    --
--  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  --
--  See the GNU General Public License for  more details.                    --
--  You should have  received  a copy of the GNU General                     --
--  Public License  distributed with Yolk.  If not, write  to  the  Free     --
--  Software Foundation,  51  Franklin  Street,  Fifth  Floor, Boston,       --
--  MA 02110 - 1301, USA.                                                    --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Text_Io; use Ada.Text_Io;
with Number_Theory_Tools; use Number_Theory_Tools;
with Interfaces; use Interfaces;

package body Merkle_Hellman is


   -----------------------------------------------------------------------------------
   --
   -- Decode a Charater from the index table. The index table is of size 8 and contains
   -- booleans elements corrospond to the bit positions in a 8 bit Character.
   --
   --
   -----------------------------------------------------------------------------------
   function Decode_Char(Index_Table : in Index_Array_T) return Character is
      Char    : Unsigned_8 := 0;

   begin
      for I in Index_Table'First .. Index_Table'Last loop
         if Index_Table(I) then
            Char := Char or (2 ** Natural(Index_Table'Last-I));
         end if;
      end loop;
      return  Character'Val(Char);
   end Decode_Char;



   -----------------------------------------------------------------------------------
   --
   -- Crypt a single block element using the Knapsack.
   --
   -----------------------------------------------------------------------------------
   function Crypt_Element(Element : Character; Knapsack : Large_Positive_Array_T) return Large_Positive is
      Char           : constant Unsigned_8     := Unsigned_8(Character'Pos(Element));
      Element_Value  : Large_Positive          := 0;

   begin
      for I in reverse Knapsack'First .. Knapsack'Last loop
         if (Char and (2 ** Natural(Knapsack'Last-I))) /= 0 then
            Element_Value := Element_Value + Knapsack(I);
         end if;
      end loop;
       return Element_Value;
   end Crypt_Element;


   -----------------------------------------------------------------------------------
   --
   -- Crypt a block of the message equal to the size of the Knapsack.
   --
   -----------------------------------------------------------------------------------
   procedure Crypt_Message(Message_Block : in String;
                           Knapsack      : in Large_Positive_Array_T;
                           Cipher        : out Large_Positive_Array_T) is

   begin
      for I in Message_Block'First .. Message_Block'Last loop
        Cipher(Large_Positive(I)) := Crypt_Element(Message_Block(I), Knapsack);
      end loop;
   end Crypt_Message;



   -----------------------------------------------------------------------------------
   --
   -- Decrypt a single block element.
   --
   -----------------------------------------------------------------------------------
   function Decrypt_Element(Element : Large_Positive;
                            K             : in Large_Positive;
                            M             : in Large_Positive;
                            Knapsack      : in Large_Positive_Array_T) return Character is

      Easy_Element : constant Large_Positive := (Element mod M) * (K mod M) mod M;
      Index_Table  : Index_Array_T (1..Knapsack'Length) := (others => False);

   begin
      Solve_Knapsack(Knapsack, Index_Table, Easy_Element);
      return Decode_Char(Index_Table);
   end Decrypt_Element;


   -----------------------------------------------------------------------------------
   --
   -- Decrypt a block of the message equal to the size of the Knapsack.
   --
   -----------------------------------------------------------------------------------
   procedure Decrypt_Message(Cipher        : in Large_Positive_Array_T;
                             K             : in Large_Positive;
                             M             : in Large_Positive;
                             Knapsack      : in Large_Positive_Array_T;
                             Message_Block : out String) is
   begin

      for I in Cipher'First .. Cipher'Last loop
        Message_Block(Integer(I)) := Decrypt_Element(Cipher(I),K,M,Knapsack);
      end loop;
   end Decrypt_Message;


   -----------------------------------------------------------------------------------
   --
   -- Print all elements in the knapsack
   --
   -----------------------------------------------------------------------------------
   procedure Print_Knapsack(Knapsack : Large_Positive_Array_T) is
   begin
      for I in Knapsack'First .. Knapsack'Last loop
         Put(Unsigned_32'Image(Unsigned_32(Knapsack(I))) & " ");
      end loop;
      New_Line;
   end Print_Knapsack;


   -----------------------------------------------------------------------------------
   --
   -- Runs the Merkle Hellman example
   --
   -----------------------------------------------------------------------------------
 procedure MH_Example is
    K : Large_Positive := 0;
    M: Large_Positive := 0;

    Limit : constant Large_Positive := 8;
    Easy_Knapsack : Large_Positive_Array_T( 1..Limit);
    Difficult_Knapsack : Large_Positive_Array_T( 1..Limit);


    Plain_Text        : constant String := "This is the clear text to be crypted";
    Cipher_Text       : Large_Positive_Array_T (1..Plain_Text'Length);
    Decrypted_Message : String(1..Plain_Text'Length);

 begin
    Generate_Easy_Knapsack(Easy_Knapsack);
    Put("Easy Easy_Knapsack: ");
    Print_Knapsack(Easy_Knapsack);
    Convert_Easy_Knapsack_To_Difficult(Easy_Knapsack, Difficult_Knapsack, K, M);
    Put("Difficult Knapsack: ");
    Print_Knapsack(Difficult_Knapsack);
    Put_Line("K = " & Integer'Image(Integer(K)) & " M = " &  Integer'Image(Integer(M)));


    Crypt_Message(Plain_Text, Difficult_Knapsack, Cipher_Text);
    Put("Cipher Text : ");
    Print_Knapsack(Cipher_Text);

    Decrypt_Message(Cipher_Text,K,M,Easy_Knapsack, Decrypted_Message);
    Put_Line("Decrypted : " & Decrypted_Message);


 end MH_Example;

 end Merkle_Hellman;


