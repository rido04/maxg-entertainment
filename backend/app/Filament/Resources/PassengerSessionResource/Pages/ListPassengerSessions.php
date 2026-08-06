<?php

namespace App\Filament\Resources\PassengerSessionResource\Pages;

use App\Filament\Resources\PassengerSessionResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListPassengerSessions extends ListRecords
{
    protected static string $resource = PassengerSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('refresh')
                ->label('Refresh Data')
                ->icon('heroicon-o-arrow-path')
                ->action(fn () => $this->resetTableFiltersForm()),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('All Sessions')
                ->badge(fn () => \App\Models\PassengerSession::count()),

            'today' => Tab::make('Today')
                ->modifyQueryUsing(fn (Builder $query) => $query->whereDate('start_time', today()))
                ->badge(fn () => \App\Models\PassengerSession::whereDate('start_time', today())->count()),

            'this_week' => Tab::make('This Week')
                ->modifyQueryUsing(fn (Builder $query) => $query->thisWeek())
                ->badge(fn () => \App\Models\PassengerSession::thisWeek()->count()),

            'this_month' => Tab::make('This Month')
                ->modifyQueryUsing(fn (Builder $query) => $query->thisMonth())
                ->badge(fn () => \App\Models\PassengerSession::thisMonth()->count()),

            'male' => Tab::make('Male Passengers')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('gender', 'male'))
                ->badge(fn () => \App\Models\PassengerSession::where('gender', 'male')->count())
                ->badgeColor('info'),

            'female' => Tab::make('Female Passengers')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('gender', 'female'))
                ->badge(fn () => \App\Models\PassengerSession::where('gender', 'female')->count())
                ->badgeColor('warning'),
        ];
    }
}
