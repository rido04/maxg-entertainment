@extends('layouts.app')

@section('title', 'Send Feedback - Garuda Indonesia')

@section('content')
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-orange-50 py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-2xl mx-auto">
            <!-- Logo Space -->
            <div class="text-center mb-12">
                <div class="w-64 h-24 mx-auto mb-8 flex items-center justify-center">
                    <img src="{{ asset('Logo-Garuda-Color-Gift.gif') }}" alt="Garuda Indonesia" class="h-18 max-w-full object-contain">
                </div>
            </div>

            <!-- Header -->
            <div class="text-center mb-10">
                <h1 class="text-4xl font-bold text-gray-900 mb-4">
                    Send Your Feedback
                </h1>
                <p class="text-lg text-gray-600 max-w-md mx-auto">
                    Your voice matters to us. Help us serve you better with your valuable feedback.
                </p>
            </div>

            <!-- Main Card -->
            <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100">
                <!-- Card Header -->
                <div class="bg-gradient-to-r from-blue-900 to-blue-800 px-8 py-6">
                    <h2 class="text-2xl font-semibold text-white">
                        Share Your Experience
                    </h2>
                    <p class="text-blue-100 mt-2">
                        We value your input to continuously improve our services
                    </p>
                </div>

                <!-- Card Body -->
                <div class="px-8 py-8">
                    {{-- Success Message --}}
                    @if(session('success'))
                        <div class="mb-6 rounded-xl bg-green-50 border border-green-200 p-4">
                            <div class="flex">
                                <div class="flex-shrink-0">
                                    <svg class="h-6 w-6 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                    </svg>
                                </div>
                                <div class="ml-3">
                                    <p class="text-sm font-medium text-green-800">
                                        {{ session('success') }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    @endif

                    {{-- Feedback Form --}}
                    <form action="{{ route('feedback.store') }}" method="POST" class="space-y-6">
                        @csrf
                        
                        <!-- Category Selection -->
                        <div>
                            <label for="category" class="block text-sm font-semibold text-gray-700 mb-2">
                                Feedback Category *
                            </label>
                            <select id="category" name="category" required
                                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors @error('category') border-red-300 ring-2 ring-red-200 @enderror">
                                <option value="">Select a category</option>
                                <option value="general" {{ old('category') == 'general' ? 'selected' : '' }}>General Feedback</option>
                                <option value="bug" {{ old('category') == 'bug' ? 'selected' : '' }}>Technical Issue / Bug Report</option>
                                <option value="suggestion" {{ old('category') == 'suggestion' ? 'selected' : '' }}>Service Improvement Suggestion</option>
                                <option value="complaint" {{ old('category') == 'complaint' ? 'selected' : '' }}>Complaint</option>
                            </select>
                            @error('category')
                                <p class="mt-2 text-sm text-red-600 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                                    </svg>
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>

                        <!-- Subject -->
                        <div>
                            <label for="subject" class="block text-sm font-semibold text-gray-700 mb-2">
                                Subject *
                            </label>
                            <input id="subject" name="subject" type="text" required
                                   value="{{ old('subject') }}"
                                   placeholder="Brief subject of your feedback"
                                   class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors @error('subject') border-red-300 ring-2 ring-red-200 @enderror">
                            @error('subject')
                                <p class="mt-2 text-sm text-red-600 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                                    </svg>
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>

                        <!-- Message -->
                        <div>
                            <label for="message" class="block text-sm font-semibold text-gray-700 mb-2">
                                Your Message *
                            </label>
                            <textarea id="message" name="message" rows="5" required
                                      placeholder="Please share your detailed feedback here. Your input helps us improve our services..."
                                      class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors resize-none @error('message') border-red-300 ring-2 ring-red-200 @enderror">{{ old('message') }}</textarea>
                            @error('message')
                                <p class="mt-2 text-sm text-red-600 flex items-center">
                                    <svg class="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                                    </svg>
                                    {{ $message }}
                                </p>
                            @enderror
                        </div>

                        <!-- Submit Button -->
                        <div class="pt-4">
                            <button type="submit"
                                    class="w-full bg-gradient-to-r from-blue-900 to-blue-800 hover:from-blue-800 hover:to-blue-700 text-white font-semibold py-4 px-6 rounded-lg transition-all duration-200 transform hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 shadow-lg hover:shadow-xl">
                                <span class="flex items-center justify-center">
                                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"/>
                                    </svg>
                                    Send Feedback
                                </span>
                            </button>
                        </div>

                        <!-- Back Link -->
                        <div class="text-center pt-4">
                            <a href="{{ url('/') }}" 
                               class="inline-flex items-center text-blue-800 hover:text-blue-900 font-medium transition-colors">
                                <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
                                </svg>
                                Back 
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Footer Note -->
            <div class="text-center mt-8">
                <p class="text-sm text-gray-500">
                    Your feedback is confidential and will be used to improve our services. 
                    <br>Thank you for flying with Garuda Indonesia.
                </p>
            </div>
        </div>
    </div>

    <!-- Custom Styles -->
    <style>
        /* Custom focus styles for better accessibility */
        input:focus, select:focus, textarea:focus {
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }
        
        /* Smooth transitions */
        * {
            transition: all 0.2s ease-in-out;
        }
        
        /* Custom scrollbar for textarea */
        textarea::-webkit-scrollbar {
            width: 6px;
        }
        
        textarea::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 3px;
        }
        
        textarea::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }
        
        textarea::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
    </style>
@endsection