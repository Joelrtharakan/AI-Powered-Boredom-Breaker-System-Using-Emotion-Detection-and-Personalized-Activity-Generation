import { useState } from 'react';
import { motion } from 'framer-motion';
import { Save, Calendar, Mic, Sparkles, ChevronRight, PenTool } from 'lucide-react';

export default function Journal() {
    const [entries, setEntries] = useState([
        { id: 1, title: "Morning Reflection", date: "Oct 24", preview: "Today I woke up feeling..." },
        { id: 2, title: "Ideas for Project", date: "Oct 22", preview: "Maybe I should try..." },
        { id: 3, title: "Anxiety Log", date: "Oct 20", preview: "Just took a deep breath..." },
    ]);
    const [selectedId, setSelectedId] = useState(null);
    const [title, setTitle] = useState('');
    const [content, setContent] = useState('');
    const [aiPrompt, setAiPrompt] = useState('');

    const generatePrompt = () => {
        const prompts = [
            "What is one thing that made you smile today?",
            "Describe a challenge you overcame recently.",
            "If you could travel anywhere right now, where would it be?",
            "List 3 things you are grateful for."
        ];
        setAiPrompt(prompts[Math.floor(Math.random() * prompts.length)]);
    };

    const handleSave = () => {
        if (!title && !content) return;
        setEntries([{ id: Date.now(), title: title || "Untitled", date: "Just now", preview: content.slice(0, 20) + "..." }, ...entries]);
        setTitle('');
        setContent('');
        setSelectedId(null);
    };

    return (
        <div className="h-screen bg-dark flex overflow-hidden pt-16">
            {/* Sidebar List */}
            <div className="w-80 border-r border-white/5 bg-dark-card/50 flex flex-col">
                <div className="p-6 border-b border-white/5">
                    <h2 className="text-xl font-bold flex items-center gap-2">
                        <PenTool size={20} className="text-primary-light" />
                        My Journal
                    </h2>
                    <button
                        onClick={() => { setSelectedId(null); setTitle(''); setContent(''); }}
                        className="btn-primary w-full mt-6 py-2 text-sm"
                    >
                        + New Entry
                    </button>
                </div>

                <div className="flex-1 overflow-y-auto p-4 space-y-2">
                    {entries.map(entry => (
                        <div
                            key={entry.id}
                            onClick={() => setSelectedId(entry.id)}
                            className={`p-4 rounded-xl cursor-pointer transition-colors ${selectedId === entry.id ? 'bg-primary/20 border border-primary/30' : 'hover:bg-white/5 border border-transparent'
                                }`}
                        >
                            <div className="flex justify-between items-start mb-1">
                                <h3 className="font-bold text-sm text-gray-200">{entry.title}</h3>
                                <span className="text-[10px] text-gray-500 uppercase tracking-wider">{entry.date}</span>
                            </div>
                            <p className="text-xs text-gray-500 truncate">{entry.preview}</p>
                        </div>
                    ))}
                </div>
            </div>

            {/* Main Editor */}
            <div className="flex-1 relative flex flex-col bg-gradient-to-br from-dark to-primary-dark/10">
                <div className="p-6 border-b border-white/5 flex justify-between items-center bg-dark/50 backdrop-blur-md z-10">
                    <div className="flex items-center gap-4">
                        <span className="text-gray-500 text-sm">{new Date().toLocaleDateString()}</span>
                        {aiPrompt && (
                            <motion.div
                                initial={{ opacity: 0, x: -10 }}
                                animate={{ opacity: 1, x: 0 }}
                                className="flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 border border-primary/20 text-xs text-primary-glow"
                            >
                                <Sparkles size={12} />
                                {aiPrompt}
                            </motion.div>
                        )}
                    </div>
                    <div className="flex gap-3">
                        <button onClick={generatePrompt} className="p-2 rounded-lg hover:bg-white/10 text-gray-400 hover:text-white" title="AI Prompt">
                            <Sparkles size={18} />
                        </button>
                        <button onClick={handleSave} className="flex items-center gap-2 px-4 py-2 bg-white text-dark font-bold rounded-lg text-sm hover:scale-105 transition-transform">
                            <Save size={16} /> Save
                        </button>
                    </div>
                </div>

                <div className="flex-1 p-8 md:p-12 overflow-y-auto w-full max-w-4xl mx-auto">
                    <input
                        type="text"
                        placeholder="Entry Title..."
                        className="w-full bg-transparent text-4xl font-bold placeholder-gray-700 border-none focus:outline-none mb-6 text-white"
                        value={title}
                        onChange={e => setTitle(e.target.value)}
                    />
                    <textarea
                        className="w-full h-full bg-transparent resize-none text-lg leading-relaxed placeholder-gray-700 border-none focus:outline-none text-gray-300 font-light"
                        placeholder="Start typing your thoughts..."
                        value={content}
                        onChange={e => setContent(e.target.value)}
                    />
                </div>
            </div>
        </div>
    )
}
