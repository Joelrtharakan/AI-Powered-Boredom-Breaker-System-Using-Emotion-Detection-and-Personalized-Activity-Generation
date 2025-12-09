export default function Lockbox() {
    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen">
            <div className="mb-12">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-indigo-500 mb-2">Mood Lockbox</h1>
                <p className="text-gray-300">Encrypted storage for your deepest thoughts.</p>
            </div>

            <div className="grid md:grid-cols-2 gap-8">
                <div className="glass-card flex flex-col items-center justify-center p-12 gap-6">
                    <div className="text-6xl">🔒</div>
                    <input type="password" placeholder="Enter PIN" className="input-field text-center text-2xl tracking-widest max-w-[200px]" />
                    <button className="btn-primary w-full max-w-[200px]">Unlock</button>
                </div>

                <div className="glass-card opacity-50 flex items-center justify-center">
                    <p>Select a slot to unlock</p>
                </div>
            </div>
        </div>
    )
}
