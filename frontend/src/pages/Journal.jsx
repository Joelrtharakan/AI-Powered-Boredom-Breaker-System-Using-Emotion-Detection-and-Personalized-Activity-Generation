import { useState } from 'react';
import axios from 'axios';

export default function Journal() {
    const [entry, setEntry] = useState('');

    const saveEntry = async () => {
        // Mock save
        alert('Entry saved!');
        setEntry('');
    };

    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen">
            <div className="mb-8">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-pink-400 to-rose-500 mb-2">Mind Dump</h1>
                <p className="text-gray-300">Clear your head. Start writing.</p>
            </div>

            <div className="glass-card h-[60vh] flex flex-col">
                <textarea
                    className="flex-1 bg-transparent resize-none focus:outline-none text-lg leading-relaxed p-4 scrollbar-hide"
                    placeholder="Today I feel..."
                    value={entry}
                    onChange={e => setEntry(e.target.value)}
                />
                <div className="flex justify-between items-center border-t border-white/10 pt-4 mt-4">
                    <span className="text-xs text-gray-500">{entry.length} chars</span>
                    <button onClick={saveEntry} className="btn-primary">Save Entry</button>
                </div>
            </div>
        </div>
    )
}
