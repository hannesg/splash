# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2010 by Hannes Georg
#
require "sync.rb"
# This is a dummy, which will simply do nothing, but works exactly
# like sync. You can use it as a replacement for every Sync when
# you have no need for thread safety.
class Sync
  
  class Dummy < self
  
    def sync_lock(mode=EX)
      return unlock if mode == UN
      @__sync_locked = true
    end
    
    def sync_unlock(mode=EX)
      @__sync_locked = false
    end
    
  end
  
end