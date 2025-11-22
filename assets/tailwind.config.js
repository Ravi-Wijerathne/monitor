module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/**/*.ex",
    "../lib/**/*.heex",
    "../lib/**/*.eex"
  ],
  theme: {
    extend: {
      colors: {
        gray: {
          900: '#0f172a',
          800: '#1e293b',
          700: '#334155',
        }
      }
    },
  },
  plugins: [],
}
