-------------------------------------------------------------------------------
--                                                                           --
--                                   RSA                                     --
--                                                                           --
--                                 RSA.ads                                   --
--                                                                           --
--                                  SPEC                                     --
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
with Number_Theory_Tools; use Number_Theory_Tools;

package RSA is

   type Char_Array_T is array (Large_Positive range <>) of Character;

   type Char_Range is new Character range 'A' .. 'Z';
   type Char_Index_Array_T is array (Char_Range range <>) of Large_Positive;

   Alphabet : Char_Array_T :=  ('A','B','C','D','E','F','G','H','I','J','K','L','M',
                                'N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

   Char_Index : Char_Index_Array_T := (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,
                                      19,20,21,22,23,24,25,26);
   procedure RSA_Example;
end RSA;
