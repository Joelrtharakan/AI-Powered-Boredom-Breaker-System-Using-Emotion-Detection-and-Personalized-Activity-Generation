export default function Music() {
    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen">
            <div className="mb-12">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-green-400 to-emerald-500 mb-2">Sonic Heal</h1>
                <p className="text-gray-300">Curated playlists for your current mood.</p>
            </div>

            <div className="glass-card flex items-center justify-center h-64">
                <p className="text-xl text-gray-400">Spotify Integration Required</p>
            </div>
        </div>
    )
}
