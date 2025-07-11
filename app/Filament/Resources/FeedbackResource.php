<?php

namespace App\Filament\Resources;

use Filament\Forms;
use Filament\Tables;
use App\Models\Feedback;
use Filament\Forms\Form;
use Filament\Tables\Table;
use Filament\Resources\Resource;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\BadgeColumn;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use App\Filament\Resources\FeedbackResource\Pages;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use App\Filament\Resources\FeedbackResource\RelationManagers;

class FeedbackResource extends Resource
{
    protected static ?string $model = Feedback::class;

    protected static ?string $navigationIcon = 'heroicon-o-chat-bubble-left-right';

    protected static ?string $navigationLabel = 'Feedback';

    protected static ?string $pluralModelLabel = 'Feedback';

    protected static ?string $modelLabel = 'Feedback';

    public static ?int $navigationSort = 4;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                //
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('subject')
                    ->label('Subjek')
                    ->searchable()
                    ->sortable()
                    ->limit(50),

                BadgeColumn::make('category')
                    ->label('Kategori')
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'general' => 'General',
                        'bug' => 'Bug Report',
                        'suggestion' => 'Suggestion',
                        'complaint' => 'Complaint',
                        default => $state,
                    })
                    ->colors([
                        'secondary' => 'general',
                        'danger' => 'bug',
                        'success' => 'suggestion',
                        'warning' => 'complaint',
                    ]),
                TextColumn::make('message')
                    ->label('Pesan')
                    ->searchable(),

                TextColumn::make('created_at')
                    ->label('Tanggal')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'new' => 'New',
                        'in_progress' => 'In Progress',
                        'resolved' => 'Resolved',
                    ]),

                SelectFilter::make('category')
                    ->label('Kategori')
                    ->options([
                        'general' => 'General',
                        'bug' => 'Bug Report',
                        'suggestion' => 'Suggestion',
                        'complaint' => 'Complaint',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListFeedback::route('/'),
            'create' => Pages\CreateFeedback::route('/create'),
            'edit' => Pages\EditFeedback::route('/{record}/edit'),
        ];
    }
}
