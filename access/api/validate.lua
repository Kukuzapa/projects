-- Вывод валидатора по-умолчанию

function validateResult ( suc, err, msg )
	return {
		json = {
			success = succ,
			error = err,
			message = msg
		}
	}
end
