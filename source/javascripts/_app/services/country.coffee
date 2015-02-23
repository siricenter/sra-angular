window.app.service "Country", ( firebase, firebaseURL ) ->
	@all = ( orgId ) ->
		url = "#{ firebaseURL }/organizations/#{ orgId }/countries"
		onLoadPromise = firebase.queryArray(url)
		return onLoadPromise

	@find = ( orgId, countryId ) ->
		url = "#{ firebaseURL }/organizations/#{ orgId }/countries/#{ countryId }"
		onLoadPromise = firebase.queryObject( url )
		return onLoadPromise
	return

