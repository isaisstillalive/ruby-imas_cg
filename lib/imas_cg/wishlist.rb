# coding: utf-8

module ImasCG
	class Wishlist
		include Enumerable
		
		def initialize service
			@service = service
		end

		def each
			@service.get_wishlist.each do |idol|
				yield idol
			end
		end

		def << digest
			@service.regist_wishlist digest
		end

		def delete id
			@service.removes_wishlist id
		end
	end
end
