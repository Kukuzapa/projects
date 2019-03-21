-- Вывод валидатора по-умолчанию

function validateResult ( suc, err, msg )
	return {
		json = {
			success = suc,
			error = err,
			message = msg
		}
	}
end
