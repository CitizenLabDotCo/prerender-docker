const ALLOWED = [
	'server',
];
const DISALLOWED = [
	'strict-transport-security',
];

module.exports = {
	pageLoaded(req, res, next) {
		// Prevent certain headers from leaking back, and proxy certain headers
		Object.keys(req.prerender.headers)
			.filter(key => DISALLOWED.includes(key.toLowerCase()))
			.forEach(key => delete req.prerender.headers[key]);

		Object.entries(req.prerender.headers)
			.filter(([key]) => ALLOWED.includes(key.toLowerCase()))
			.forEach(([key, value]) => res.setHeader(`X-Upstream-${key}`, value));

		next();
	}
};
